function [v] = checkVariable(variable)
    v = exist('variable','var') && ~isempty(variable);
    