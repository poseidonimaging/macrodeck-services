module Utils
    def assign_when_undef(var,value)
        var = value unless defined? var
    end
    
    def human_time(time_int)
        Time.at(time_int).to_s
    end
end