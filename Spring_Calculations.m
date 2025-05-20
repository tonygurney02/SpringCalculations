clear
close 
clc
%known measurements 

Length_max = 20; %inches
Stretch_length_min = 35; %in
Load_target = 600; %lbs

%material propterties for music wire
G = 11.5e6; % Shear modulus (psi) for ASTM A228 music wire
S_u = 300000; % Ultimate tensile strength (psi)
S_s = 0.45 * S_u; % Shear strength (psi)
tolerance = 10;

C= 6:.1:12; % Assume a spring index C = Dm/d

delta = abs(Length_max-Stretch_length_min); % Deflection
k_target = Load_target / delta; % Spring stiffness (lbs/in)

% Define range for wire diameter (d) and number of active coils (Na)
d = .01:.01:1; % Wire diameter range (in inches)
Na = 10:1:100; % Number of active coils

In_requirements = []; % Store valid d and Na values
%Loop over wire diameters and number of active coils
for i = 1:length(d)
    for j = 1:length(Na)
        for l = 1:length(C)
            Dm = C(l) * d(i); % Mean coil diameter

            % Wahl's correction factor
            Kw = (4 * C(l) - 1) / (4 * C(l) - 4) + 0.615 / C(l);

            % Max load from shear stress
            Load = (S_s * pi * d(i)^3) / (8 * Dm * Kw);

            %fprintf("load = %g",Load)

            % Spring stiffness
            k = (G * d(i)^4) / (8 * Dm^3 * Na(j));

            %fprintf("K = %g",k)

            Length = (Na(j)+2)*d(i);

            Stretch_length = Load/k;

            % Check conditions
            if Load > Load_target && (k - k_target)>tolerance && Length < Length_max && Stretch_length > Stretch_length_min

                OD = (C(l)+1)*d(i);
                In_requirements = [In_requirements; d(i), Na(j),OD,Length,Stretch_length,Load,k,C(l)]; % Store valid pairs
            end
        end
    end
end

% Display results
if isempty(In_requirements)
    disp('No suitable wire diameter and coil number found within constraints.');
else
    disp('Suitable wire diameter and coil number found:');
    disp(array2table(In_requirements, 'VariableNames', {'Wire_Diameter', 'Active_Coils', 'Outer_Diameter', 'Length','Max Stretch Length','Max Load','k-value','Spring index'}));
end
