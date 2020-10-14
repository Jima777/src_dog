clear
clc
robot=importrobot('Leg.urdf');
show(robot);
axes.CameraPositionMode = 'auto';
%% Define the trajectory as a circle with a radius of 0.15
t = (0:0.2:20)';
count = length(t);
center = [0.0575 0 -0.4];
radius = 0.1;
theta = t*(2*pi/t(end));
points =(center + radius*[cos(theta) sin(theta) zeros(size(theta))])';
%% Draw the defined trajectory and inverse kinematics solution
hold on
plot3(points(1,:),points(2,:),points(3,:),'r')
%eeOffset = 0.01;
%eeBody = robotics.RigidBody('end_effector');%����ĩ��ִ���������ٺ�����ӵ������˵�Link5��
%setFixedTransform(eeBody.Joint,trvec2tform([eeOffset 0 0]));
%addBody(robot,eeBody,'puma_link_5');
ik = robotics.InverseKinematics('RigidBodyTree',robot);%��������
weights = [0.1 0.1 0 0 0 0]; %Ȩ��
qInitial = robot.homeConfiguration;
%%
%ͨ����Ĺ켣ѭ��������Բ������ÿ�����ik����������ʵ��ĩ��λ�õĹؽ����ã��洢Ҫ�Ժ�ʹ�õ��������
for i = 1:size(points,2)
% Solve for the configuration satisfying the desired end effector
tform = rpy2tr(136,-180,-180);%��̬��ξ���
tform = trvec2tform(points(:,i)')*tform ;%ĩ��λ����ξ���
qSol = ik('fl_foot',tform,weights,qInitial);%�����ؽڽǶ�
% Start from prior solution
qInitial = qSol;
end
%% ������ʾ
title('robot move follow the trajectory')
hold on
axis([-0.8 0.8 -0.8 0.85 0 1.3]);
for i = 1:size(points,2)
show(robot,qSol','PreservePlot',false);%false��Ϊtrueʱ��������Ӱ��
pause(0.3)
plot3(points(1,i),points(2,i),points(3,i),'.','LineWidth',1);
end