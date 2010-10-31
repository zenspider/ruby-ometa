def leterize(s)
	trans={"."=>"_dot_","_"=>"_","-"=>"_minus_","="=>"_equal_","<" => "_less_",">"=>"_greater_","$"=>"_dollar_"}
	s2=""
	s=s.split("")
	s.each{|e|s2+=trans[e]?trans[e]:e }
	s2
end
