% 验证机器人动力学是否正确
clear;
clc;

LegDynamicParams;

%q = [0 0 0];
%dq = [0 10 0];
%ddq = [0 0 0];
%g_num = [0 0 0];

q = randn(1, 3);
dq = randn(1, 3) * 10;
ddq = randn(1, 3) * 10;
g_num = randn(1, 3) * 10;

sym_list = [
    hip_len_x hip_len_y thigh_offset_z shin_offset_z ...
    hip_x hip_y ...
    m_hip m_thigh m_shin ...
    com_hip_x com_hip_y ...
    com_thigh_y com_thigh_z ...
    com_shin_z ...
    I1xx I1xy I1yy I1zz ...
    I2xx I2yy I2yz I2zz ...
    I3xx I3yy I3zz ...
    g_x g_y g_z ...
    q1 q2 q3 ...
    vq1 vq2 vq3 ...
    aq1 aq2 aq3
    ];
sub_list = [
    0.053   0.0575  -0.2    -0.2    ...
    0.23    0.0605	...
    0.650   0.863   0.119   ...
    0.050160        -0.013329       ...
    29.693E-3       -13.531E-3      ...
    -93.811E-3      ...
    399.183E-6      -13.085E-6      708.749E-6      460.327E-6  ...
    2082.653E-6     2271.664E-6     -261.229E-6     617.145E-6  ...
    827.276E-6      834.282E-6      15.950E-6       ...
    g_num   ...
    q   ...
    dq  ...
    ddq
    ];

robot = importrobot("Leg.urdf");
robot.DataFormat = 'row';
robot.Gravity = g_num;

tau_real = inverseDynamics(robot, q, dq, ddq);

tau_lagrange = eval(subs(torq, sym_list, sub_list));

disp([
    tau_real
    tau_lagrange
    ]);
