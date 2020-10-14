% ���ű����ڼ�¼��������ǰ�ȵĳ��ȡ�������ر���
% �������ڻ������˶�ѧ�Ƶ���

% ��ǰ�ȳ��Ȳ�����������ȳ���С�ȳ�����������������Ϊ��
syms hip_len_x hip_len_y thigh_offset_z shin_offset_z; 

syms hip_x hip_y; % ���������ĵ㵽��ǰ�ȵ�λ��
syms q1 q2 q3; % �ؽڽǶ�

c1 = cos(q1);
s1 = sin(q1);
c2 = cos(q2);
s2 = sin(q2);
c3 = cos(q3);
s3 = sin(q3);

% �ӿ赽���ɵ���α任����
T1 = [
    1   0   0   hip_x
    0   c1  -s1 hip_y
    0   s1  c1  0
    0   0   0   1
    ];
% T1 * ���ڿ�ο�ϵ������ = �������ɲο�ϵ������

% �Ӵ��ȵ������α任����
T2 = [
    c2  0   s2  hip_len_x
    0   1   0   hip_len_y
    -s2 0   c2  0
    0   0   0   1
    ];

% ��С�ȵ����ȵ���α任����
T3 = [
    c3  0   s3  0
    0   1   0   0
    -s3 0   c3  thigh_offset_z
    0   0   0   1
    ];

% ĩ����С�Ȳο�ϵ�е����꣨��Σ�
FootLocalPos = [
    0
    0
    shin_offset_z
    1
    ];
