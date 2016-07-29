function [obj,user]=attachUE(obj,user)
idx=obj.current_UE_number;
obj.attachedUE(idx+1)=user.id;
obj.current_UE_number=idx+1;
end