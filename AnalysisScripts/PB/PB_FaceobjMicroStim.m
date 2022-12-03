
subplot(2,2,1);
hold on;
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(2,:)','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(3,:)','r-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(4,:)','k-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(5,:)','c-','linewidth',2)
axis([0 500 -10 140]);
subplot(2,2,2);
hold on;
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(18,:)','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(19,:)','r-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(20,:)','k-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(21,:)','c-','linewidth',2)
axis([0 500 -10 140]);
subplot(2,2,3);
hold on;
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(7,:)','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(8,:)','r-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(9,:)','k-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(10,:)','c-','linewidth',2)

axis([0 500 -10 140]);

figure;
subplot(2,2,1);
hold on;
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(2,:)','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(3,:)','r-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(4,:)','k-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(5,:)','c-','linewidth',2)
subplot(2,2,2);
hold on;
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(18,:)','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(19,:)','r-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(20,:)','k-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(21,:)','c-','linewidth',2)
subplot(2,2,3);
hold on;
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(7,:)','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(8,:)','r-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(9,:)','k-','linewidth',2)
plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(10,:)','c-','linewidth',2)

