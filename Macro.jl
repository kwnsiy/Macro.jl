# coding:utf-8

@windows_only println("unix環境推奨")

""" @swap! """
macro swap!(x,y)
  quote
    $(esc(x)) = $(eval(y))
    $(esc(y)) = $(eval(x))
    return
  end
end

""" @cd """
macro cd(obj)
  :(cd($obj))
end

""" @pwd """
macro pwd()
  :(pwd())
end

""" @head """
macro head(filename)
  quote
    $(run(`head $filename -n 3`))
  end
end

""" @dir """
macro dir(pass...)
  return readdir(pass...)
end


""" @replace! """
macro replace!(string, pat, r)
  quote
    $(esc(string)) = $(eval(replace(eval(string),eval(pat), eval(r))))
    return
  end
end

""" @assign! """
macro assign!(a, b)
  quote
    $(esc(a)) = $(eval(b))
    return
  end
end

""" @toCmd """
macro toCmd(string)
  return `$string`
end


""" @run """
macro run(cmd)
  quote
    $(run(eval(cmd)))
  end
end

""" @split! """
macro split!(string, chars)
  quote
    $(esc(string)) = $(eval(split(eval(string),eval(chars))))
    return
  end
end

""" @rstrip! """
macro rstrip!(string)
  quote
    $(esc(string)) = $(eval(rstrip(eval(string))))
    return
  end
end


""" @println """
macro println(obj...)
  :(println($obj...))
end


""" @print """
macro print(obj...)
  :(print($obj...))
end


""" @inc! """
macro inc!(x)
   :($x += 1)
end


""" @decr! """
macro decr!(x)
  :($x -= 1)
end

""" iconv """
function iconv(inputfile, outputfile, from, to)
  return readall(pipeline(`iconv -f $from -t $to $inputfile`, outfile))
end


# convert any character encoding to utf8
""" readall_utf8 """
function readall_utf8(filename)
  return readall(pipeline(`iconv -t UTF-8 $filename`))
end

function readall_utf8(filename, from)
  return readall(pipeline(`iconv -f $from -t UTF-8 $filename`))
end


""" cabocha_parser """
function cabocha_parser(sentence, option)
  return readall(pipeline(`echo $sentence`, `cabocha -$option`))
end

function cabocha_parser(sentence)
  sentence = replace(sentence, "\n", "")
  result = readall(pipeline(`echo $sentence`, `cabocha -f1`))
  d = Dict(:chunk_id => Array{Int, 1}(), :chunk => Array{UTF8String,1}(), :tok_surface => Array{Array{UTF8String,1},1}(),
           :tok_feature => Array{Array{UTF8String,1},1}(), :link => Array{Int, 1}(), :head => Array{Int, 1}(), :func => Array{Int, 1}())
  for line in split(result, "\n")
    line == "EOS" && break
    if ismatch(r"^\* \d+", line)
     tmp = split(line)
     push!(d[:chunk_id], parse(tmp[2])+1)
     push!(d[:chunk], "")  
     push!(d[:link], parse(tmp[3][1:end-1])+1)
     head, func = map(parse, split(tmp[4], "/"))
     push!(d[:head], head+1)
     push!(d[:func], func+1)
     push!(d[:tok_surface], Array{UTF8String,1}())
     push!(d[:tok_feature], Array{UTF8String,1}())
    else
     surface, feature = split(line, "\t")
     d[:chunk][end] = d[:chunk][end]*surface
      push!(d[:tok_surface][end], surface)
      push!(d[:tok_feature][end], feature)
    end
  end
  return d
end





