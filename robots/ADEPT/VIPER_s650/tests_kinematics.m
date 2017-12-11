% SCRIPT TEST FOR THE KINEMATIC PROBLEM FOR SERIAL ROBOTS

% Copyright (C) 2012, by Arturo Gil Aparicio
%
% This file is part of ARTE (A Robotics Toolbox for Education).
% 
% ARTE is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% ARTE is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with ARTE.  If not, see <http://www.gnu.org/licenses/>.

close all

fprintf('\nTHE DEMO PRESENTS THE DIRECT AND INVERSE KINEMATIC PROBLEM')

%there are eight possible solutions for the inverse kinematic problem for most of these robots
n_solutions = 8;

%Try different configurations beware that, depending on the robot's topology
%not all the eight possible solutions will be feasible for an antropomorphic 6R robot.
%q=[0 -pi/4 pi/4 0 pi/4 pi/4]
q = [pi/8 pi/4  -2*pi/3 0 pi/4 0];
%q = [0.1 -pi/4 pi/4 0.1 0.1 0.1];


robot=load_robot('ALUMNOS','VIPER_s650\VIPER_s650'); n_solutions=8;


%adjust 3D view as desired
adjust_view(robot)

%draw the robot
drawrobot3d(robot, q)

%Now compute direct kinematics for this position q
T = directkinematic(robot, q)

%Set to zero if you want to see the robot transparent
robot.graphical.draw_transparent=0;

%Set to one if you want to see the DH axes
%abb.graphical.draw_axes=1;

%Call the inversekinematic for this robot. All the possible solutions are
%stored at qinv. At least, one of the possible solutions should match q
qinv = inversekinematic(robot, T);


fprintf('\nNOW WE CAN REPRESENT THE DIFFERENT SOLUTIONS TO ACHIEVE THE SAME POSITION AND ORIENTATION\n')
fprintf('\nNot that some solutions may not be feasible. Some joints may be out of range\n')
correct=zeros(1,n_solutions);
%check that all of them are possible solutions!
for i=1:size(qinv,2),
    
    Ti = directkinematic(robot, qinv(:,i)) %Ti is constant for the different solutions    
    
    % Note that all the solutions may not be feasible. Some of the joints may
    % be out of range. You can test this situation with test_joints
    test_joints(robot, qinv(:,i));
    
    
    %now draw the robot to see the solution
    drawrobot3d(robot, qinv(:,i))
    
    pause(1);
    
    k=sum(sum((T-Ti).^2));
    if k < 0.01 % a simple threshold to find differences in the solution
        correct(1,i)= 1;        
    else
        correct(1,i)= 0; %uncorrect solution
        fprintf('\nERROR: One of the solutions seems to be uncorrect. Sum of errors: %f', i, k);
    end
end
%Display a message if any of the solutions is not correct
if sum(correct)==n_solutions
    fprintf('\nOK: Every solution in qinv yields the same position/orientation T');
else
    fprintf('\nERROR: One or more of the solutions seems to be uncorrect.');
end

%Now, test if any of the solutions in qinv matches q
%find the solution that matches the initial q
%delta is just a squared sum of errors at each of the columns of the matrix
%which store the different solutions of qinv
delta=(repmat(q',[1 n_solutions])-qinv).^2;
i=find(sum(delta,1)<0.01);
if ~isempty(i)
    fprintf('\nOK!: Found a matching solution:\n');
    qinv(:,i)
else
    fprintf('\nERROR: Did not find a matching solution for the initial q');
end