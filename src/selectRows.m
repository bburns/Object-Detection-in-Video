
% returns a new matrix with only rows matching the 
% criteria m(:,col)==value

function mnew = selectRows(m, col, value)

ind = find(m(:,col)==value);
mnew = m(ind,:);

end

