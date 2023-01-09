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

length(c::Component{<: Any}) = parse(Int64, c["height"])

width(c::Component{:circle}) = parse(Int64, c["r"])

width(c::Component{<: Any}) = parse(Int64, c["width"])

center(c::Component{<: Any}) = begin
    p = position(c)
    p.x += width(c) / 2
    p.y += length(c) / 2
    p
end

center(c::Component{:circle}) =  position(c)

position(comp::Component{:circle}) = Vec2(parse(Int64, comp["cx"]),
        parse(Int64, comp["cy"]))

position(comp::Component{<:Any}) = Vec2(parse(Int64, comp["x"]),
                parse(Int64, comp["y"]))

delta(c::Connection) = c[:VultaCore].deltas[find_client(c)]

initializing(c::Connection) = delta(c) == 1

function spawn!(c::Connection, vm::AbstractComponentModifier, s::Component{<: Any},
    v::Vec2 = Vec2(0, 0); decay::Int64 = 1)
    c[:VultaCore].fields[replace(find_client(c), "rpc" => "")][s] = v
    s["x"] = v.x; s["y"] = v.y; s["fx"] = 0; s["fy"] = 0; s["decay"] = decay
    style!(s, "transition" => ".2s")
    append!(vm, "vulta-main", s)
end

function spawn!(c::Connection, vm::AbstractComponentModifier, s::Component{:circle}, v::Vec2 = Vec2(0, 0);
    decay::Int64 = 1)
    c[:VultaCore].fields[replace(find_client(c), "rpc" => "")][s] = v
    s["cx"] = v.x; s["cy"] = v.y; s["fx"] = 0; s["fy"] = 0; s["decay"] = decay
    style!(s, "transition" => ".2s")
    append!(vm, "vulta-main", s)
end

function is_colliding(vm::AbstractComponentModifier, s1::Component{<:Any},
    s2::Component{<:Any})
    s1 = vm.rootc[s1.name]
    s2 = vm.rootc[s2.name]
    s1pos = center(s1); s2pos = center(s2)
    diffx, diffy = abs(s1pos.x - s2pos.x), abs(s1pos.y - s2pos.y)
    combined_width::Int64 = width(s1) / 2 + width(s2) / 2
    combined_length::Int64 = length(s1) / 2 + length(s2) / 2
    if abs(diffy) <= combined_length && abs(diffx) <= combined_width
        true
    else
        false
    end
end

above(v::Vec2, v2::Vec2) = begin

end

function translate!(cm::AbstractComponentModifier, comp::Component{:circle}, v::Vec2)
    cm[comp] = "cx" => v.x; cm[comp] = "cy" => v.y
end

function translate!(cm::AbstractComponentModifier, comp::Component{<: Any}, v::Vec2)
    cm[comp] = "x" => v.x; cm[comp] = "y" => v.y
end

function force!(cm::AbstractComponentModifier, s::Component{<:Any}, force::Vec2)
    cm[s] = "fx" => parse(Int64, cm[s]["fx"]) + force.x
    cm[s] = "fy" => parse(Int64, cm[s]["fy"]) + force.y
end

function hard_force!(cm::AbstractComponentModifier, s::Component{<:Any}, force::Vec2)
    cm[s] = "fx" => force.x
    cm[s] = "fy" => force.y
end
