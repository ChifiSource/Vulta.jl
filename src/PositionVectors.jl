abstract type VultaVector end

mutable struct Vec2 <: VultaVector
    x::Int64
    y::Int64
end

mutable struct Vec3 <: VultaVector
    x::Int64
    y::Int64
    z::Int64
end

length(c::Component{:circle}) = parse(Int64, c["r"])

length(c::Component{:rect}) = parse(Int64, c["length"])

width(c::Component{:circle}) = parse(Int64, c["r"])

width(c::Component{:rect}) = parse(Int64, c["width"])

position(comp::Component{:circle}) = Vec2(parse(Int64, comp["cx"]),
        parse(Int64, comp["cy"]))

position(comp::Component{<:Any}) = Vec2(parse(Int64, comp["x"]),
                parse(Int64, comp["y"]))

delta(c::Connection) = c[:VultaCore].deltas[find_client(c)]

function spawn!(vm::AbstractComponentModifier, s::Component{<: Any}, v::Vec2 = Vec2(0, 0);
    decay::Int64 = 1)
    s["x"] = v.x; s["y"] = v.y; s["fx"] = 0; s["fy"] = 0; s["decay"] = decay
    style!(s, "transition" => 1seconds)
    append!(vm, "vulta-main", s)
end

function spawn!(vm::AbstractComponentModifier, s::Component{:circle}, v::Vec2 = Vec2(0, 0);
    decay::Int64 = 1)
    s["cx"] = v.x; s["cy"] = v.y; s["fx"] = 0; s["fy"] = 0; s["decay"] = decay
    style!(s, "transition" => 1seconds)
    append!(vm, "vulta-main", s)
end

function is_colliding(vm::AbstractComponentModifier, s1::Component{<:Any},
    s2::Component{<:Any})
    s1 = vm.rootc[s1.name]
    s2 = vm.rootc[s2.name]
    s1pos = position(s1); s2pos = position(s2)
    diffx, diffy = abs(s1pos.x - s2pos.x), abs(s1pos.y - s2pos.y)
    combined_widh::Int64 = width(s1) + width(s2)
    combined_length::Int64 = length(s1) + length(s2)
    if diffy < length(s1) && diffx < combined_width
        true
    else
        false
    end
end

function translate!(cm::AbstractComponentModifier, comp::Component{:circle}, v::Vec2)
    cm[comp] = "cx" => v.x; cm[comp] = "cy" => v.y
end

function translate!(cm::AbstractComponentModifier, comp::Component{:rect}, v::Vec2)
    cm[comp] = "x" => v.x; cm[comp] = "y" => v.y
end



function force!(cm::AbstractComponentModifier s::Component{<:Any}, force::Vec2)
    vm[s] = "fx" => force.x
    vm[s] = "fy" => force.y
end
