copyTable = function(orig)
    local orig_type = type(orig)
    if orig_type ~= 'table' then return orig end 

    local copy = {}
    for orig_key, orig_value in next, orig, nil do
        copy[copyTable(orig_key)] = copyTable(orig_value)
    end
    setmetatable(copy, copyTable(getmetatable(orig)))
    return copy
end

exports("copyTable",copyTable)