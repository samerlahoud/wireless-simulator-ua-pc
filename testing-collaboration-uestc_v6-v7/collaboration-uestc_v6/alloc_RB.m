function obj=alloc_RB(obj,RB)
    idx = obj.current_RB_number;
    obj.RB(idx+1) = RB;
    obj.current_RB_number = idx+1;
end