function numerical_branch = modify_to_numerical_branch(br)
%used for generating a copy of the branch matrix for connectivity
%calculation, which requires ordinal bus numbering

numerical_branch = br;
for i_row = 1:size(numerical_branch,1);
   numerical_branch(i_row,1) = transfer_bus(br(i_row,1));
   numerical_branch(i_row,2) = transfer_bus(br(i_row,2));
end