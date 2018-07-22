function part = link2part( obj,link )
%link2part Get the part (left_leg,right_arm) the link belongs to

part = obj.link2partMapping.(link).part;

end
