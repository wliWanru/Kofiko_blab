/*

  	PsychToolbox3/Source/windows/Base/PsychTimeGlue.c

	AUTHORS:

  	mario.kleiner at tuebingen.mpg.de		mk 

	PLATFORMS: Micro$oft Windows Only


  	PROJECTS:

  	12/27/05	mk		Screen, GetSecs, WaitSecs, KbCheck, KbWait, PsychPortAudio on M$-Windows

  	HISTORY:

  	12/27/05	mk		Wrote it. Derived from OS-X version.
	11/14/07 mk			Added tons of checking and error-handling code for broken Windoze timers.
						Added special debug helper functions to be used via GetSecs().  
	04/05/08	mk		Added locking viar time_lock to PsychGetPrecisionTimerSeconds() to protect
						against races in time glue checking code due to multiple threads calling, e.g.,
						inside the PsychPortAudio module (Portaudio callback thread and main thread).
	1/03/09		mk		Add generic Mutex locking support as service to ptb modules. Add PsychYieldIntervalSeconds().

  	DESCRIPTION:
	
	Functions for querying system time and for waiting for either a
	specified amount of time or until a specified point in time.
	Also returns timer ticks and resolution of timers.

	TO DO:

*/

#include <stdio.h>
#include "mex.h"
#include <windows.h>

typedef HANDLE					psych_condition;		
		typedef struct psych_threadstruct {
			HANDLE				handle;			// Handle to actual thread (NULL == Invalid).
			DWORD				threadId;		// Unique numeric id (0 = Invalid.)
			psych_condition		terminateReq;	// Condition/Event object to signal the request for termination.
			HANDLE				taskHandleMMCS; // Handle to task for MMCSS scheduled thread, NULL otherwise.
		} psych_threadstruct;
		typedef struct psych_threadstruct*	psych_thread;

void PsychGetPrecisionTimerSeconds(double *secs);
void PsychEstimateGetSecsValueAtTickCountZero(void);
void PsychGetAdjustedPrecisionTimerSeconds(double *secs);
void PsychGetPrecisionTimerAdjustmentFactor(double *factor);
void PsychSetPrecisionTimerAdjustmentFactor(double *factor);
int PsychInitCondition(psych_condition* condition, const void* condition_attribute);
int PsychDestroyCondition(psych_condition* condition);
int PsychSignalCondition(psych_condition* condition);

typedef CRITICAL_SECTION		psych_mutex;
typedef unsigned __int64 ULONGLONG; 
typedef unsigned long DWORD;
typedef unsigned char BYTE;
typedef unsigned short WORD;

typedef ULONGLONG                       psych_uint64;
typedef DWORD                           psych_uint32;
typedef BYTE                            psych_uint8;
typedef WORD                            psych_uint16;
typedef BOOL psych_bool                      ;


static double			precisionTimerAdjustmentFactor;
static double			estimatedGetSecsValueAtTickCountZero;
static psych_uint64		kernelTimebaseFrequencyHz;
static psych_bool       counterExists;
static psych_bool       firstTime;
static double			sleepwait_threshold;
static psych_bool		Timertrouble;
static psych_bool 		schedulingtrouble;
static double			tickInSecsAtLastQuery;
static double			timeInSecsAtLastQuery;
 
typedef psych_uint32		psych_threadid;

// Our critical section variable to guarantee exclusive access to PsychGetPrecisionTimerSeconds()
// in order to prevent race-conditions for the timer correctness checks in multi-threaded code:
CRITICAL_SECTION	time_lock;

void PsychGetPrecisionTimerTicks(psych_uint64 *ticks);
bool init_mod = false;

void PsychWaitUntilSeconds(double whenSecs)
{
  static unsigned int missed_count=0;
  double now=0.0;

  // Get current time:
  PsychGetPrecisionTimerSeconds(&now);

  // If the deadline has already passed, we do nothing and return immediately:
  if (now > whenSecs) return;

  // Note that technically there is potential for a race-condition on the
  // sleepwait_threshold and missed_count variables if multiple threads
  // inside the same PTB module call PsychWaitUntilSeconds concurrently
  // and miss their deadlines simultaneously --> concurrent update of that
  // vars. However, currently no modules do this concurrently in threads,
  // and even if, the worst case outcome -- sleepwait_threshold incrementing
  // slower than possible -- is perfectly tolerable. Therefore we safe us
  // the locking overhead here.

  // Waiting stage 1: If we have more than sleepwait_threshold seconds left
  // until the deadline, we call the OS Sleep() function, so the
  // CPU gets released for difference - sleepwait_threshold s to other processes and threads.
  // -> Good for general system behaviour and for lowered
  // power-consumption (longer battery runtime for Laptops) as
  // the CPU can go idle if nothing else to do...
  while(whenSecs - now > sleepwait_threshold) {

	 // Sleep until only sleepwait_threshold away from deadline:
    Sleep((int)((whenSecs - now - sleepwait_threshold) * 1000.0f));

	 // Recheck:
    PsychGetPrecisionTimerSeconds(&now);
  }

  // Waiting stage 2: We are less than sleepwait_threshold s away from deadline.
  // Perform busy-waiting until deadline reached:
  while(now < whenSecs) PsychGetPrecisionTimerSeconds(&now);

  // Check for deadline-miss of more than 1 ms:
  if (now - whenSecs > 0.001) {
    // Deadline missed by over 1 ms.
    missed_count++;

    if (missed_count>5) {
      // Too many consecutive misses. Increase our threshold for sleep-waiting
      // by 5 ms until it reaches 20 ms.
      if (sleepwait_threshold < 0.02) sleepwait_threshold+=0.005;
      printf("PTB-WARNING: Wait-Deadline missed for %i consecutive times (Last miss %0.6f ms). New sleepwait_threshold is %0.6f ms.\n",
	     missed_count, (now - whenSecs)*1000.0f, sleepwait_threshold*1000.0f);
		// Reset missed count after increase of threshold:
		missed_count = 0;
    }
  }
  else {
    // No miss detected. Reset counter...
    missed_count=0;
  }

  // Ready.
  return;
}

void PsychWaitIntervalSeconds(double delaySecs)
{
  double deadline;
  
  if (delaySecs <= 0) return;
  
  // Get current time:
  PsychGetPrecisionTimerSeconds(&deadline);
  // Compute deadline in absolute system time:
  deadline+=delaySecs;
  // Wait until deadline reached:
  PsychWaitUntilSeconds(deadline);
  return;
}

/* PsychYieldIntervalSeconds() - Yield the cpu for given 'delaySecs'
 *
 * PsychYieldIntervalSeconds() differs from PsychWaitIntervalSeconds() in that
 * it is supposed to release the cpu to other threads or processes for *at least*
 * the given amount of time 'delaySecs', instead of *exactly* 'delaySecs'.
 *
 * If one wants to wait an exact amount of time, one uses PsychWaitIntervalSeconds().
 * If one just "has nothing to do" for some minimum amount of time, and wants to
 * play nice to other threads/processes and exact timing is not crucial, then
 * this is the routine of choice. Typical use is within polling loops, where one
 * wants to pause between polling cycles and it doesn't matter if the pause takes
 * a bit longer.
 *
 * A 'delaySecs' of <= zero will just release the cpu for the remainder of
 * the current scheduling timeslice. If you don't know what to do, choose a
 * zero setting.
 *
 */
void PsychYieldIntervalSeconds(double delaySecs)
{
	if (delaySecs <= 0) {
		// Yield cpu for remainder of this timeslice via special Sleep(0) call:
		Sleep(0);
	}
	else {
		// On MS-Windows we can't use PsychWaitIntervalSeconds(), as all
		// its clever compensation mechanisms for the shoddy Windows schedulers
		// flaws would likely turn the yield() into a cpu hogging busy-wait
		// spinloop, which is not what we want!
		//
		// Therefore we use the Win32 function Sleep() directly, with a minimum
		// sleep duration of 1 msec (or more). The requested sleep duration will
		// turn into anything from 1 msec to multiple milliseconds for minimum
		// sleep. For a multi-msecs sleep we can assume that it will sleep longer
		// than requested by up to multiple msecs. Anyway, it will release the cpu...
		delaySecs = (delaySecs > 0.001) ? delaySecs : 0.001;
		Sleep((int) (delaySecs * 1000.0f));
	}
}

double	PsychGetKernelTimebaseFrequencyHz(void)
{
  return((double) kernelTimebaseFrequencyHz);
}


/* Called at module init time: */
void PsychInitTimeGlue(void)
{
	LARGE_INTEGER	counterFreq;

	// Initialize our timeglue mutex:

	// Alternative would be InitializeCriticalSection().
	// Needs define _WIN32_WINNT as 0x0403 or later. 
	// This would be good to use, but my old Windows2000 box doesn't support it:
	//if (!InitializeCriticalSectionAndSpinCount(&time_lock, 0x80000400)) {
	//	// We're screwed:
	//	printf("PTBCRITICAL -ERROR: In PsychInitTimeGlue() - failed to init time_lock!!! May malfunction or crash soon....\n");
	//}

	// Setup defaults for all state variables:
	precisionTimerAdjustmentFactor=1;
	kernelTimebaseFrequencyHz = 0;
	if (QueryPerformanceFrequency(&counterFreq)) {
		kernelTimebaseFrequencyHz = (psych_uint64) counterFreq.QuadPart;
	}
	
	counterExists=FALSE;
	firstTime=TRUE;
	sleepwait_threshold = 0.003;
	Timertrouble = FALSE;
	schedulingtrouble = FALSE;
	tickInSecsAtLastQuery = -1;
	timeInSecsAtLastQuery = -1;
	
	// That is why we use the less capable critical section init call:
	// Has less capable error handling etc., but what can one do...
	InitializeCriticalSection(&time_lock);

	// Setup mapping of ticks to time:
	PsychEstimateGetSecsValueAtTickCountZero();

	
}

/* Called at module shutdown/jettison time: */
void PsychExitTimeGlue(void)
{
	// Release our timeglue mutex:
	DeleteCriticalSection(&time_lock);

	return;
}

void PsychGetPrecisionTimerTicks(psych_uint64 *ticks)
{
  LARGE_INTEGER	                count;
  if (QueryPerformanceFrequency(&count) && !Timertrouble) {
    QueryPerformanceCounter(&count);
    *ticks = (psych_uint64) count.QuadPart;
  }
  else {
    *ticks = (psych_uint64) timeGetTime();
  }
  return;
}

void PsychGetPrecisionTimerTicksPerSecond(double *frequency)
{
  LARGE_INTEGER	                counterFreq;

  // High precision timer available?
  if (QueryPerformanceFrequency(&counterFreq) && !Timertrouble) {
    // Yes. Returns its operating frequency:
    *frequency=(double) counterFreq.QuadPart;
  }
  else {
    // No. Return the 1 khZ tickfreq of the system tick.
    *frequency=1000.0f;
  }
  return;
}

double PsychMapPrecisionTimerTicksToSeconds(psych_uint64 ticks)
{
	if (!Timertrouble) {
		return((double) ticks / (double) kernelTimebaseFrequencyHz);
	}
	else {
		return(-1);
	}
}

void PsychGetPrecisionTimerTicksMinimumDelta(psych_uint32 *delta)

{
  // FIXME: Don't know if this is correct!
  *delta=1;
}

void PsychGetPrecisionTimerSeconds(double *secs)
{
  double					ss, ticks, diff;
  static LARGE_INTEGER		counterFreq;
  LARGE_INTEGER				count;
  static double				oss;
  static double				oldticks;
  static double				lastSlowcheckTimeSecs;
  static double				lastSlowcheckTimeTicks;
  psych_uint32				tick1, tick2, hangcount;
  psych_uint64				curRawticks;
  
	// First time init of timeglue: Set up system for high precision timing,
	// and enable workarounds for broken systems:
  if (firstTime) {

		// Init state to defaults:
		oss=0.0;
		oldticks=0.0;
		lastSlowcheckTimeSecs = -1;
		lastSlowcheckTimeTicks = -1;
		
		// Switch the system into high resolution timing mode, i.e.,
		// 1 khZ timer interrupts aka 1 msec timer resolution, for both,
		// the Sleep() command and TimeGetTime() queries. This way, our hybrid
		// sleep-waiting algorithm for PsychWaitUntilSeconds() can work with
		// tight busy-wait transition thresholds and doesn't burn too much
		// CPU time. The timeGetTime() function then gets sufficient granularity -
		// 1 msecs - to be a good reference for our correctness/consistency
		// checks on the high precision timer, and it is a sufficient fallback
		// in case of broken timers.
		// The drawback is increased general interrupt load due to the 1 kHZ IRQ's...
    	if ((timeBeginPeriod(1)!=TIMERR_NOERROR) && (schedulingtrouble == FALSE)) {
		  	// High precision mode failed! Output warning on first failed invocation...
		  	schedulingtrouble = TRUE;
        	printf("PTBCRITICAL -ERROR: PsychTimeGlue - Win32 syscall timeBeginPeriod(1) failed!!! Timing will be inaccurate.\n");
        	printf("PTBCRITICAL -ERROR: Time measurement may be highly unreliable - or even false!!!\n");
        	printf("PTBCRITICAL -ERROR: FIX YOUR SYSTEM! In its current state its not useable for conduction of studies!!!\n");
        	printf("PTBCRITICAL -ERROR: Check the FAQ section of the Psychtoolbox Wiki for more information.\n");

		  	// Increase switching threshold to 10 msecs to take low timer resolution into account:
		  	sleepwait_threshold = 0.010;
    	}    

	 	// This command timeEndPeriod(1); should be used when flushing the MEX file, but
		// we don't do it. Once a PsychTimeGlue function was called, we leave Matlab at
		// high timing precision mode and rely on the OS to revert to standard Windoze
		// behaviour, once the Matlab application is quit/terminated.

		// Next step for broken systems: Bind our Matlab interpreter/PTB main thread to the
		// first cpu core in the system. The only known way to make sure we don't get time
		// readings from different TSCs due to our thread jumping between cpu's. TSC's on
		// a multi-core system are not guaranteed to be synchronized, so if TSC is our timebase,
		// this could lead to time inconsistencies - even time going backwards between queries!!!
		// Drawback: We may not make optimal use of a multi-core system.
		if (SetThreadAffinityMask(GetCurrentThread(), 1)==0) {
		  	// Binding failed! Output warning on first failed invocation...
		  	schedulingtrouble = TRUE;
        	printf("PTBCRITICAL -ERROR: PsychTimeGlue - Win32 syscall SetThreadAffinityMask() failed!!! Timing could be inaccurate.\n");
        	printf("PTBCRITICAL -ERROR: Time measurement may be highly unreliable - or even false!!!\n");
        	printf("PTBCRITICAL -ERROR: FIX YOUR SYSTEM! In its current state its not useable for conduction of studies!!!\n");
        	printf("PTBCRITICAL -ERROR: Check the FAQ section of the Psychtoolbox Wiki for more information.\n");
		}
		
		// Sleep us at least 10 msecs, so the system will reschedule us, with the
		// thread affinity mask above applied. Don't know if this is needed, but
		// better safe than sorry:
		Sleep(10);
		
		// Spin-Wait until timeGetTime() has switched to 1 msec resolution:
		hangcount = 0;
		while(hangcount < 100) {
			tick1 = (psych_uint32) timeGetTime();
			while((tick2=(psych_uint32) timeGetTime()) == tick1);
			if ((tick2 > tick1) && (tick2 - tick1 == 1)) break;
			hangcount++;
		}

		if (hangcount >= 100) {
			// Totally foobared system! Output another warning but try to go on. Checks further below in code
			// will trigger and provide counter measures - as far as this is possible with such a screwed system :-(
			printf("PTB-CRITICAL WARNING! Timing code detected problems with the low precision TIMER in your system hardware!\n");
			printf("PTB-CRITICAL WARNING! It doesn't run at the requested rate of 1 tick per millisecond. Interrupt problems?!?\n");
			printf("PTB-CRITICAL WARNING! Your system is somewhat screwed up wrt. timing!\n");
			printf("PTB-CRITICAL WARNING! It is NOT RECOMMENDED to continue using this machine for studies that require high\n");
			printf("PTB-CRITICAL WARNING! timing precision in stimulus onset or response collection. No guarantees can be made\n");
			printf("PTB-CRITICAL WARNING! wrt. to timing or correctness of any timestamps or stimulus onsets!\n");
			printf("PTB-CRITICAL WARNING! Check the FAQ section of the Psychtoolbox Wiki for more information.\n\n");
		}

		// Ok, now timeGetTime() should have the requested 1 msec increment rate.

		// Ok, this is a dumb solution, but at least sort of robust. The
		// proper solution will have to wait for the next 'beta' release cycle.
		// We don't allow to use any timing function on a Windoze system that
		// has more than 48 days of uptime. Rationale: At 49.8 days, the 32 bit
		// tick counter will wrap around and leave our fallback- and reference
		// timebase in an undefined state. Implementing proper wraparound handling
		// for inifinite uptimes is not simple, due to PTB's modular nature and
		// some special flaws of Windoze. Anyway, 48 days uptime is unlikely
		// anyway, unless the user doesn't perform regular system updates...
		if (((double) timeGetTime() * 0.001) > (3600 * 24 * 48)) {
			// Uptime exceeds 48 days. Say user this is a no no:
			printf("PTB-ERROR: Your system is running since over 48 days without a reboot. Due to some\n");
			printf("PTB-ERROR: pretty disgusting design flaws in the Windows operating system, timing\n");
			printf("PTB-ERROR: will become unreliable or wrong at uptimes of more than 49 days.\n");
			printf("PTB-ERROR: Therefore PTB will not continue executing any time related function unless\n");
			printf("PTB-ERROR: you reboot your machine now.\n\n");
		} 

		// Is the high-precision timer supported?
    	counterExists = QueryPerformanceFrequency(&counterFreq);
		if (counterExists) {
			// Initialize old counter values to now:
			if (0 == QueryPerformanceCounter(&count)) {
				Timertrouble = TRUE;
				counterExists = FALSE;
				oss = 0;
				
				printf("PTB-CRITICAL WARNING! Timing code detected problems with the high precision TIMER in your system hardware!\n");
				printf("PTB-CRITICAL WARNING! Initial call to QueryPerformanceCounter() failed!\n");
				printf("PTB-CRITICAL WARNING! Will switch back to lower precision/resolution timer (only +/-1 millisecond accuracy at best).\n");				
				printf("PTB-CRITICAL WARNING! This can cause a cascade of errors, failures and problems in any timing related functions!!\n\n");				
				printf("PTB-CRITICAL WARNING! It is NOT RECOMMENDED to continue using this machine for studies that require any\n");
				printf("PTB-CRITICAL WARNING! timing precision in stimulus onset or response collection. No guarantees can be made\n");
				printf("PTB-CRITICAL WARNING! wrt. to timing or correctness of any timestamps or stimulus onsets!\n");
				printf("PTB-CRITICAL WARNING! Read 'help GetSecsTest' and run GetSecsTest for further diagnosis and troubleshooting.\n");
				printf("PTB-CRITICAL WARNING! It may also help to restart the machine to see if the problem is transient.\n");
				printf("PTB-CRITICAL WARNING! Also check the FAQ section of the Psychtoolbox Wiki for more information.\n\n");
			}
			else {
				oss = ((double)count.QuadPart)/((double)counterFreq.QuadPart);
			}
		}
		
		// Sleep us another 10 msecs to make sure there is a significant difference between
		// first invocation and successive invocations:
		Sleep(10);
  }
  
	// Query system time of low resolution counter:
	curRawticks = timeGetTime();

	// Need to acquire our timelock before we continue, as we will soon access shared data structures:
	EnterCriticalSection(&time_lock);

	// Convert to ticks in seconds for further processing:
	ticks = ((double) curRawticks) * 0.001;
	tickInSecsAtLastQuery = ticks;
	
	
  if (counterExists) {
	// Query Performance counter:
	if (0 == QueryPerformanceCounter(&count)) {
			Timertrouble = TRUE;
			printf("PTB-CRITICAL WARNING! Timing code detected problems with the high precision TIMER in your system hardware!\n");
			printf("PTB-CRITICAL WARNING! A call to QueryPerformanceCounter() failed!\n");
			printf("PTB-CRITICAL WARNING! Will switch back to lower precision/resolution timer (only +/-1 millisecond accuracy at best).\n");
			printf("PTB-CRITICAL WARNING! It is NOT RECOMMENDED to continue using this machine for studies that require high\n");
			printf("PTB-CRITICAL WARNING! timing precision in stimulus onset or response collection. No guarantees can be made\n");
			printf("PTB-CRITICAL WARNING! wrt. to timing or correctness of any timestamps or stimulus onsets!\n");
			printf("PTB-CRITICAL WARNING! Read 'help GetSecsTest' and run GetSecsTest for further diagnosis and troubleshooting.\n");
			printf("PTB-CRITICAL WARNING! It may also help to restart the machine to see if the problem is transient.\n");
			printf("PTB-CRITICAL WARNING! Also check the FAQ section of the Psychtoolbox Wiki for more information.\n\n");
	}

   ss = ((double)count.QuadPart)/((double)counterFreq.QuadPart);
   timeInSecsAtLastQuery = ss;

	// Initialize base time for slow consistency checks at first invocation:
	if (firstTime) {
		lastSlowcheckTimeSecs = ss;
		lastSlowcheckTimeTicks = ticks;
	}

	// Compute difference (disagreement over elapsed time since last call) between high-precision
	// timer and low-precision timer:
	diff = ((ss - oss) - (ticks - oldticks));

	// We don't perform the inter-timer agreement check at first invokation - Thread scheduling etc. needs to settle,
	// as well as the timeBeginPeriod(1) call above...
	if (!Timertrouble && !firstTime) {
		// No timer problems yet. Perform checks:

		// Time running backwards?
		if (ss < oss) {
			Timertrouble = TRUE;
			printf("PTB-CRITICAL WARNING! Timing code detected problems with the high precision TIMER in your system hardware!\n");
			printf("PTB-CRITICAL WARNING! Apparently time is reported as RUNNING BACKWARDS. (Timewarp Delta: %0.30f secs.)\n", ss - oss);
			printf("PTB-CRITICAL WARNING! One reason could be a multi-core system with unsynchronized TSC's and buggy platform drivers.\n");
			printf("PTB-CRITICAL WARNING! Will switch back to lower precision/resolution timer (only +/-1 millisecond accuracy at best).\n");
		}
		
		// The old and new high res. timer should not
		// disagree in their increment since last call by more than 250 msecs. If they do,
		// this means that the high precision timer leaped forward, which indicates a faulty
		// Southbridge controller in the machines host chipset - Not a good basis for high precision timing.
		// See Microsoft Knowledge base article Nr. 274323 for further explanation and a list of known bad
		// chipsets.
		// We actually allow for an additional slack of 0.000200 seconds or 200 ppm for each
		// elapsed second of the test interval. This to account for clock drift of up to 200 ppm
		// between both clocks. According to some docs, 200 ppm drift are possible under MS-Windows!
		if ( diff > ( 0.25 + ((ticks - oldticks) * 0.000200 ) ) ) {
			// Mismatch between performance counter and tick counter detected!
			// Performance counter is faulty! Report this to user, then continue
			// by use of the older tick counter as a band-aid.
			Timertrouble = TRUE;
			printf("PTB-CRITICAL WARNING! Timing code detected a FAULTY high precision TIMER in your system hardware!(Delta %0.30f secs).\n", diff);
			printf("PTB-CRITICAL WARNING! Seems the timer sometimes randomly jumps forward in time by over 250 msecs!");
			printf("PTB-CRITICAL WARNING! Will switch back to lower precision/resolution timer (only +/-1 millisecond accuracy at best).\n");
			printf("PTB-CRITICAL WARNING! For more information see Microsoft knowledge base article Nr. 274323.\n");
			printf("PTB-CRITICAL WARNING! http://support.microsoft.com/default.aspx?scid=KB;EN-US;Q274323&\n\n");
		}

		// We check for lags of QPC() wrt. to tick count at intervals of greater than 1 second, ie. only if
		// this query and the last one are at least 1 second spaced apart in time. This is kind of a low-pass
		// filter to account for the fact that the tick counter itself can sometimes lose a bit of time due
		// to lost timer interrupts, and then jump forward in time by a couple of milliseconds when some
		// system service detects the lost interrupts and accounts for them by incrementing time by multiple
		// ticks at a single IRQ. Here we check over a longer period to make it less likely that such transients
		// show up. We apply a much more generous lag threshold as well, so we can compensate for transient timer
		// jumps of up to 50 msecs.
		if ((ticks - lastSlowcheckTimeTicks) >= 1.0) {
			// Check for lags: A lag of multiple msec is normal and expected due to the measurement method.
			diff = ((ss - lastSlowcheckTimeSecs) - (ticks - lastSlowcheckTimeTicks));
						
			// Let's check for a lag exceeding 5% of the duration of the check interval, so we have a bit of headroom to the expected lag:
			if (diff < -0.05 * (ticks - lastSlowcheckTimeTicks)) {
				// Mismatch between performance counter and tick counter detected!
				// Performance counter is lagging behind realtime! Report this to user, then continue
				// by use of the older tick counter as a band-aid.
				Timertrouble = TRUE;
				printf("PTB-CRITICAL WARNING! Timing code detected a LAGGING high precision TIMER in your system hardware! (Delta %0.30f secs).\n", diff);
				printf("PTB-CRITICAL WARNING! Seems that the timer sometimes stops or slows down! This can happen on systems with\n");
				printf("PTB-CRITICAL WARNING! processor power management (cpu throttling) and defective platform drivers.\n");				
				printf("PTB-CRITICAL WARNING! Will switch back to lower precision/resolution timer (only +/-1 millisecond accuracy at best).\n");
				printf("PTB-CRITICAL WARNING! Please try if disabling all power management features of your system helps...\n");
			}
			
			// Update timestamps of last check:
			lastSlowcheckTimeSecs = ss;
			lastSlowcheckTimeTicks = ticks;
		}
		
		if (Timertrouble) {
			// More info for user at first detection of trouble:
			printf("PTB-CRITICAL WARNING! It is NOT RECOMMENDED to continue using this machine for studies that require high\n");
			printf("PTB-CRITICAL WARNING! timing precision in stimulus onset or response collection. No guarantees can be made\n");
			printf("PTB-CRITICAL WARNING! wrt. to timing or correctness of any timestamps or stimulus onsets!\n");
			printf("PTB-CRITICAL WARNING! Read 'help GetSecsTest' and run GetSecsTest for further diagnosis and troubleshooting.\n");
			printf("PTB-CRITICAL WARNING! It may also help to restart the machine to see if the problem is transient.\n");
			printf("PTB-CRITICAL WARNING! Also check the FAQ section of the Psychtoolbox Wiki for more information.\n\n");			
		}
	}

	// All checks done: Prepare old values for new iteration:
	oss = ss;
	oldticks = ticks;
	
	// Ok, is the timer finally considered safe to use?
	if (!Timertrouble) {
		// All checks passed: ss is the valid return value:
		ss = ss;
	}
	else {
		// Performance counter works unreliably: Fall back to result of timeGetTime().
		// This only has 1 msec resolution at best, but at least it works (somewhat...).
		ss = ticks;
	}	

	//  ========= End of high precision timestamping. =========
  }
  else {
	//  ========= Low precision fallback path for ancient machines: 1 khz tick counter: =========
	ss = ticks;
	timeInSecsAtLastQuery = -1;
  }

  // Finally assign time value:  
  *secs= ss;  

	// Clear the firstTime flag - this was the first time, maybe.
   firstTime = FALSE;

	// Need to release our timelock - Done with access to shared data:
	LeaveCriticalSection(&time_lock);

	return;
}


void PsychGetAdjustedPrecisionTimerSeconds(double *secs)
{
  double		rawSecs, factor;
  
  PsychGetPrecisionTimerSeconds(&rawSecs);
  PsychGetPrecisionTimerAdjustmentFactor(&factor);
  *secs=rawSecs * precisionTimerAdjustmentFactor;
}

void PsychGetPrecisionTimerAdjustmentFactor(double *factor)
{
  *factor=precisionTimerAdjustmentFactor;
}

void PsychSetPrecisionTimerAdjustmentFactor(double *factor)
{
  precisionTimerAdjustmentFactor=*factor;
}

/*
	PsychEstimateGetSecsValueAtTickCountZero()

	Note that the tick counter rolls over after a couple of months.
	Its theoretically possible to have machine uptime of that long 
	but its extremely unlikely given that this is Microsoft Windows ;)
	so we don't worry about roll over when calculating. 

*/
void PsychEstimateGetSecsValueAtTickCountZero(void)
{
  double		nowTicks, nowSecs;
  
  nowTicks=(double) timeGetTime();
  PsychGetAdjustedPrecisionTimerSeconds(&nowSecs);
  estimatedGetSecsValueAtTickCountZero=nowSecs - nowTicks * (1/1000.0f); 
}

double PsychGetEstimatedSecsValueAtTickCountZero(void)
{
  return(estimatedGetSecsValueAtTickCountZero);
}

/* Returns value of timeGetTime() based timer (in seconds) last time the
	high precision timer was queried. This is a reference value for checking
	correctness of the high precision timer with external code.
	Windows specific, only used by GetSecs() for Windows...
*/
double PsychGetTimeGetTimeValueAtLastTimeQuery(double* precisionRawtime)
{
	// Theoretically there is a potential race here, due to access to shared variables,
	// but we don't lock here -- In practice this function is only used by GetSecs
	// in special debug- and test scripts, where no parallel threading is active:
	*precisionRawtime = timeInSecsAtLastQuery;
	return(tickInSecsAtLastQuery );
}

/* Windows specific: Only used by GetSecs() - Return encoded timer healthy flags: */
unsigned int PsychGetTimeBaseHealthiness(void)
{
	unsigned int v;
	v=(Timertrouble) ? 1 : 0;
	v+=(schedulingtrouble) ? 2 : 0;
	return(v);
}

/* Init a Mutex: */
int	PsychInitMutex(psych_mutex* mutex)
{
	InitializeCriticalSection(mutex);
	return(0);
}

/* Deinit and destroy a Mutex: */
int	PsychDestroyMutex(psych_mutex* mutex)
{
	DeleteCriticalSection(mutex);
	return(0);
}

/* Lock a Mutex, blocking until mutex is available if it isn't available: */
int PsychLockMutex(psych_mutex* mutex)
{
	EnterCriticalSection(mutex);
	return(0);
}

/* Try to lock a Mutex, returning immediately, with a return code that tells if mutex could be locked or not: */
int PsychTryLockMutex(psych_mutex* mutex)
{
	// Must #define _WIN32_WINNT as at least 0x0400 in master include file PsychIncludes.h for this to compile!
	return((((int) TryEnterCriticalSection(mutex)) != 0) ? 0 : 1);
}

/* Unlock a Mutex: */
int PsychUnlockMutex(psych_mutex* mutex)
{
	LeaveCriticalSection(mutex);
	return(0);
}

/* Create a parallel thread of execution, invoke its main routine: */
/* FIXME: void* is wrong return argument type for start_routine!!! Works on Win32, but would crash on Win64!!! */
int PsychCreateThread(psych_thread* threadhandle, void* threadparams, void *(*start_routine)(void *), void *arg)
{
	// threadparams not yet used, this line just to make compiler happy:
	(void*) threadparams;
	
	*threadhandle = (psych_thread) malloc(sizeof(struct psych_threadstruct));
	if (*threadhandle == NULL) {
		printf("Error\n");
		return 1;
	}
	(*threadhandle)->handle = NULL;
	(*threadhandle)->threadId = 0;
	(*threadhandle)->taskHandleMMCS = NULL;

	// Create termination event for thread: It can be set to signalled via PsychAbortThread() and
	// threads can test for its state via PsychTestCancelThread(), which will exit the thread cleanly
	// if the event is signalled.
	(*threadhandle)->terminateReq = NULL;
	if (PsychInitCondition(&((*threadhandle)->terminateReq), NULL)) {
		printf( "Failed to initialize associated condition/signal object when trying to create processing thread!");
		return 1;
	}
	// Create thread, running, with default system settings, assign thread handle:
	(*threadhandle)->handle = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE) start_routine, arg, 0, &((*threadhandle)->threadId));
	
	// Return result code: If successfull, return 0. Otherwise return 1:
	return( ((*threadhandle)->handle != NULL) ? 0 : 1);
}

/* Join a parallel thread - Wait for its termination, then return its result code: */
int PsychDeleteThread(psych_thread* threadhandle)
{
	psych_uint32 rc;

	// Join on the thread, wait for termination:
	rc = (int) WaitForSingleObject((*threadhandle)->handle, INFINITE);
	if (WAIT_FAILED != rc) {
		// Retrieve exit code of terminated thread:
		GetExitCodeThread((*threadhandle)->handle, &rc);
		
		// Destroy its associated ressources:
		CloseHandle((*threadhandle)->handle);
	}
	else {
		printf("PTB-CRITICAL: In PsychDeleteThread: Waiting for termination of a worker thread failed! Prepare for trouble!\n");
	}
	
	// Release event/condition variable for signalling of terminate requests:
	if (PsychDestroyCondition(&((*threadhandle)->terminateReq))) printf("PTB-CRITICAL: In PsychDeleteThread: Failed to destroy associated condition/signal object when trying to delete processing thread!");

	// Null out now invalid thread handle of dead thread:
	(*threadhandle)->handle = NULL;
	(*threadhandle)->threadId = 0;
	(*threadhandle)->terminateReq = NULL;
	
	free(*threadhandle);
	*threadhandle = NULL;
	
	// Return return code of joined thread:
	return((int) rc);
}

/* Send abort request to thread: */
int PsychAbortThread(psych_thread* threadhandle)
{
	// This is an emergency abort call! Maybe should think about a "softer" solution for Windows?
	// This is more like an option for a future PsychKillThread(): return( TerminateThread((*threadhandle)->handle, 0) );
	
	// Signal the terminateReq condition variable/signal to politely ask the thread to terminate:
	return(PsychSignalCondition(&((*threadhandle)->terminateReq)));
}

/* Check for abort request to thread: Exit thread gracefully if abort requested: */
void PsychTestCancelThread(psych_thread* threadhandle)
{
	int rc;

	// Test for signalled state of abort request event with zero timeout, ie., return immediately if
	// non-signalled:
	rc = (int) WaitForSingleObject((*threadhandle)->terminateReq, 0);
	if (rc == WAIT_FAILED) {
		rc = (int) GetLastError();
		printf("PTB-CRITICAL: In call to PsychTestCancelThread(%p): WaitForSingleObject(%i) FAILED [GetLastError()=%i]! Expect disaster!!!", threadhandle, (int) (*threadhandle)->terminateReq, rc);
		return;
	}

	// Event state signalled? Otherwise we just return:
	if (rc != WAIT_OBJECT_0) return;

	// Signalled --> Terminate request: We terminate our calling thread with a zero exit code:
	ExitThread(0);
}


/* Return thread id of calling thread:
 */
psych_threadid PsychGetThreadId(void)
{
	psych_threadid threadid = (psych_threadid) GetCurrentThreadId();
	return(threadid);
}
/* Check if two given thread handles do refer to the same thread: */
int PsychIsThreadEqual(psych_thread threadOne, psych_thread threadTwo)
{
	return( threadOne->threadId == threadTwo->threadId );
}

/* Check if current (invoking) thread has an id equal to given threadid: */
int PsychIsCurrentThreadEqualToId(psych_threadid threadId)
{
	return( PsychGetThreadId() == threadId );
}

/* Check if current (invoking) thread is equal to given threadhandle: */
int PsychIsCurrentThreadEqualToPsychThread(psych_thread threadhandle)
{
	return( PsychGetThreadId() == threadhandle->threadId );
}

/* Change priority for thread 'threadhandle', or for the calling thread if 'threadhandle' == NULL.
 * 'basePriority' can be 0 for normal scheduling, 1 for higher priority and 2 for highest priority.
 * 'tweakPriority' modulates more fine-grained within the category given by 'basepriority'. It
 * can be anywhere between 0 and 2 where bigger means more priority.
 *
 * See http://msdn.microsoft.com/en-us/library/ms684247(VS.85).aspx for explanation of the MMCSS
 * scheduling services on Vista and later. The short story is: A non-Administrator user can usually
 * get no more than HIGH_PRIORITY scheduling for the Matlab/Octave process, and even for admin users,
 * running with REALTIME_PRIORTY is usually too dangerous with most Psychtoolbox applications. If we
 * are able to use MMCSS scheduling on Vista and later, we get something better than HIGH_PRIORITY,
 * pretty close to REALTIME_PRIORITY, but with a safety net that should prevent disaster, assuming
 * the Windows MMCSS service knows what it is doing...
 *
 * Returns zero on success, non-zero on failure to set new priority.
 */
int PsychSetThreadPriority(psych_thread* threadhandle, int basePriority, int tweakPriority)
{
	int rc;
	HANDLE thread;

	if (NULL != threadhandle) {
		// Retrieve thread HANDLE of thread to change:
		thread = (*threadhandle)->handle;
	}
	else {
		// Retrieve handle of calling thread:
		thread = GetCurrentThread();
	}

	switch(basePriority) {
		case 0:	// Normal priority.
			rc = SetThreadPriority(thread, THREAD_PRIORITY_NORMAL);
			if (rc == 0) {
				rc = GetLastError();	// Failed!
			}
			else {
				rc = 0;
			}
			
		break;
		
		case 1: // High priority / Round robin realtime.
			rc = SetThreadPriority(thread, THREAD_PRIORITY_HIGHEST);
			if (rc == 0) {
				rc = GetLastError();	// Failed!
			}
			else {
				rc = 0;
			}
		break;
		
		case 2: // Highest priority: This preempts basically any system service!
			if ((rc = SetThreadPriority(thread, THREAD_PRIORITY_TIME_CRITICAL)) == 0) {
				// Failed to get TIME_CRITICAL priority!
				// Try to get as close as possible to TIME_CRITICAL. On Vista and later,
				// we can try to abuse MMCSS scheduling to get to a pretty high priority,
				// certainly higher than HIGHEST, close to TIME_CRITICAL:
				// MMCSS not supported on pre-Vista system, or thread not eligible for MMCSS.
					// Retry with HIGHEST priority, the best we can do on pre-Vista:
					rc = SetThreadPriority(thread, THREAD_PRIORITY_HIGHEST);
				 
			}
			if (rc == 0) {
				rc = GetLastError();	// Failed!
			}
			else {
				rc = 0;
			}
		break;

		case 10: // MMCSS scheduling: Vista, Windows-7 and later only...
				// MMCSS not supported on pre-Vista system, or thread not eligible for MMCSS.
				// Retry with HIGHEST priority, the best we can do on pre-Vista:
				rc = SetThreadPriority(thread, THREAD_PRIORITY_HIGHEST);
		break;

		default:
			printf("PTB-CRITICAL: In call to PsychSetThreadPriority(): Invalid/Unknown basePriority %i provided!\n", basePriority);
			rc = 2;
	}

	// rc is either zero for success, or 2 for invalid arg, or some other non-zero GetLastError() failure code:
	return(rc);
}

/* Initialize condition variable:
 * CAUTION: Use of condition_attribute is not supported! Code using it may or may not work properly
 * on MS-Windows! Pass NULL for this argument for portable operation!
 */
int PsychInitCondition(psych_condition* condition, const void* condition_attribute)
{
	// Catch unsupported use of condition_attribute and output warning:
	if (NULL != condition_attribute) 
		printf("Tried to pass a condition_attribute in call to PsychInitCondition()! Unsupported on MS-Windows!!");

	// Create properly initialized event object: Will return NULL on failure.
	*condition =	CreateEvent(NULL,	// default security attributes
								FALSE,	// auto-reset event: This would need to be set TRUE for PsychBroadcastCondition() to work on Windows!
								FALSE,	// initial state is nonsignaled
								NULL	// no object name
								); 

	// Return 0 on success, GetLastError() error code on failure:
	return((int) ((*condition == NULL) ? GetLastError() : 0));
}

/* Destroy condition variable: */
int PsychDestroyCondition(psych_condition* condition)
{
	return((int) ((CloseHandle(*condition) == 0) ? GetLastError() : 0));
}

/* Signal/wakeup exactly one thread waiting on the given condition variable: */
int PsychSignalCondition(psych_condition* condition)
{
	return((int) ((SetEvent(*condition) == 0) ? GetLastError() : 0));
}

/* Signal/Wakeup all threads waiting on the given condition variable:
 * CAUTION: Use of this function is non-portable to MS-Windows for now! Code
 * using it will malfunction if used on MS-Windows!
 */
int PsychBroadcastCondition(psych_condition* condition)
{
	// Abort for now: PulseEvent(), besides being flaky anyway, would need Event objects
	// with the auto-reset property set to TRUE. We don't support this, neither can we
	// support intermixing calls to PsychSignalCondition() with calls to PsychBroadcastCondition()
	// in any way on Windows - It is simply not possible. One would need to create each condition
	// for either being useable for one method or the other and then carefully keep track of past
	// usage.
	printf("Tried to call PsychBroadcastCondition()! Unsupported on MS-Windows!!");

	// According to MSDN, PulseEvent is unreliable and should not be used.
	return((int) ((PulseEvent(*condition) == 0) ? GetLastError() : 0));
}

/* Atomically release the 'mutex' lock and go to sleep, waiting for the 'condition' variable
 * being signalled, then waking up and trying to re-lock the 'mutex'. Will return with
 * mutex locked.
 */
int PsychWaitCondition(psych_condition* condition, psych_mutex* mutex)
{
	int rc, rc2;

	// MS-Windows: Unlock mutex, wait for our event-object to go to signalled
	// state, then reacquire the mutex:
	if ((rc = PsychUnlockMutex(mutex))) {
		printf("PTB-CRITICAL: In call to PsychWaitCondition(%p, %p): PsychUnlockMutex(%p) FAILED [rc=%i]! Expect disaster!!!", condition, mutex, mutex, rc);
		return(rc);
	}
	
	if ((rc = WaitForSingleObject(*condition, INFINITE)) != WAIT_OBJECT_0) {
		rc = (int) GetLastError();
		printf("PTB-CRITICAL: In call to PsychWaitCondition(%p, %p): WaitForSingleObject(%p) FAILED [GetLastError()=%i]! Expect disaster!!!", condition, mutex, condition, rc);
	}
	
	if ((rc2 = PsychLockMutex(mutex))) {
		printf("PTB-CRITICAL: In call to PsychWaitCondition(%p, %p): PsychLockMutex(%p) FAILED [rc=%i]! Expect disaster!!!", condition, mutex, mutex, rc2);
		return(rc2);
	}
	
	return(rc);
}

/* Atomically release the 'mutex' lock and go to sleep, waiting for the 'condition' variable
 * being signalled, then waking up and trying to re-lock the 'mutex'. Will return with
 * mutex locked.
 *
 * Like PsychWaitCondition, but function will timeout if it fails being signalled before
 * timeout interval 'maxwaittimesecs' expires. In any case, it will only return after
 * reacquiring the mutex. It will retun zero on successfull wait, non-zero (WAIT_TIMEOUT) if
 * timeout was triggered without the condition being signalled.
 */
int PsychTimedWaitCondition(psych_condition* condition, psych_mutex* mutex, double maxwaittimesecs)
{
	int rc, rc2;
	int maxmillisecs;

	if (maxwaittimesecs < 0) {
		printf("PTB-CRITICAL: In call to PsychTimedWaitCondition(%p, %p, %f): NEGATIVE timeout value passed! Clamping to zero! Expect trouble!!", condition, mutex, maxwaittimesecs);
		maxmillisecs = 0;
	}
	else {
		// Convert seconds to milliseconds:
		maxmillisecs = (int) (maxwaittimesecs * 1000.0);
	}
	
	// MS-Windows: Unlock mutex, wait for our event-object to go to signalled
	// state, then reacquire the mutex:
	if ((rc = PsychUnlockMutex(mutex))) {
		printf("PTB-CRITICAL: In call to PsychTimedWaitCondition(%p, %p, %f): PsychUnlockMutex(%p) FAILED [rc=%i]! Expect disaster!!!", condition, mutex, maxwaittimesecs, mutex, rc);
		return(rc);
	}
	
	rc = (int) WaitForSingleObject(*condition, (DWORD) maxmillisecs);
	if ((rc != WAIT_OBJECT_0) && (rc != WAIT_TIMEOUT)) {
		rc = (int) GetLastError();
		printf("PTB-CRITICAL: In call to PsychTimedWaitCondition(%p, %p, %f): WaitForSingleObject(%p, %i) FAILED [GetLastError()=%i]! Expect disaster!!!", condition, mutex, maxwaittimesecs, condition, maxmillisecs, rc);
	}
	
	if ((rc2 = PsychLockMutex(mutex))) {
		printf("PTB-CRITICAL: In call to PsychTimedWaitCondition(%p, %p, %f): PsychLockMutex(%p) FAILED [rc=%i]! Expect disaster!!!", condition, mutex, maxwaittimesecs, mutex, rc2);
		return(rc2);
	}
	
	// Success: Either in the sense of "signalled" or in the sense of "timeout".
	// rc will tell the caller what happened: 0 = Signalled, 0x00000102L == WAIT_TIMEOUT for timeout.
	return(rc);
}
void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{

if (!init_mod) {
	init_mod = true;
	PsychInitTimeGlue();
}

	double now;
    PsychGetAdjustedPrecisionTimerSeconds(&now);
	plhs[0] = mxCreateDoubleScalar(now);


}