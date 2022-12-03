
function num = findcond(Name1)

  if strcmpi(Name1(1:4),'face');
        num = str2num(Name1(end-1:end));
    elseif strcmpi(Name1(1:5),'blank');
        num = 0;
    elseif strcmpi(Name1(1:6),'object');
        num = 3 + str2num(Name1(end-1:end));
    elseif strcmpi(Name1(1:5),'Noise');
        num = 7;
  end
   