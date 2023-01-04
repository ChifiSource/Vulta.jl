module Vulta
using Toolips
using ToolipsSession
using ToolipsSVG
import ToolipsSession: rpc!

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

mutable struct VultaModifier{V <: VultaVector} <: ToolipsSession.AbstractComponentModifier
    c::Connection
    delta::Int64
    rootc::Dict{String, Servable}
    changes::Vector{String}
    function VultaModifier(c::Connection,
        delta::Int64, width::Int64, height::Int64, cm::ComponentModifier)
        comps::Dict{String, Vec2} = Dict{String, Vec2}()
        new{Vec2}(c, delta, cm.rootc, cm.changes)
    end
    function VultaModifier(delta::Int64, width::Int64, height::Int64, depth::Int64,
         cm::ComponentModifier)
         throw!("3D has not been implemented")
    end
end

function open(f::Function, c::Connection, bod::Component{:body},
    width::Int64 = 1280, height::Int64 = 720; tickrate::Int64 = 100)
    open_rpc!(c, "vulta-rpc", tickrate = tickrate)
    push!(c[:Session].peers,
     getip(c) => Dict{String, Vector{String}}(getip(c) => Vector{String}()))
     delta::Int64 = 0
    script!(c, getip(c) * "rpc", time = tickrate) do cm::ComponentModifier
        delta += 1
        push!(cm.changes, join(c[:Session].peers[getip(c)][getip(c)]))
        vm = VultaModifier(c, delta, width, height, cm)
        [force(cm, comp) for comp in values(cm.rootc)]
        f(vm)
        c[:Session].peers[getip(c)][getip(c)] = Vector{String}()
    end
    wind = svg("vulta-main", width = width, height = height)
    push!(bod, wind)
    style!(wind, "padding" => 0px, "position" => "absolute")
    write!(c, bod)
end

length(c::Component{:circle}) = parse(Int64, c["r"])

length(c::Component{:rect}) = parse(Int64, c["length"])

width(c::Component{:circle}) = parse(Int64, c["r"])

width(c::Component{:rect}) = parse(Int64, c["width"])

function force(cm::ComponentModifier, comp::Component{:circle})
    if ~("fx" in keys(comp.properties))
        return
    end
    decay = parse(Int64, comp["decay"])
    currx = parse(Int64, comp["cx"])
    curry = parse(Int64, comp["cy"])
    fx = parse(Int64, comp["fx"])
    fy = parse(Int64, comp["fy"])
    if fx != 0
        cm[comp] = "cx" => currx + fx
        if fx > 0
            cm[comp] = "fx" => (fx - decay)
        else
            cm[comp] = "fx" => fx + (decay)
        end
    elseif fy != 0
        cm[comp] = "cy" => curry + fy
        if fy > 0
            cm[comp] = "fy" => (fy - decay)
        else
            cm[comp] = "fy" => fy + (decay)
        end
    end
end

function force(cm::ComponentModifier, comp::Component{<:Any})
    if ~("fx" in keys(comp.properties))
        return
    end
end

function force(cm::ComponentModifier, comp::Component{:rect})
    if ~("fx" in keys(comp.properties))
        return
    end
    decay = parse(Int64, comp["decay"])
    currx = parse(Int64, comp["x"])
    curry = parse(Int64, comp["y"])
    fx = parse(Int64, comp["fx"])
    fy = parse(Int64, comp["fy"])
    if fx != 0
        cm[comp] = "x" => currx + fx
        if fx > 0
            cm[comp] = "fx" => (fx - decay)
        else
            cm[comp] = "fx" => fx + (decay)
        end
    elseif fy != 0
        cm[comp] = "y" => curry + fy
        if fy > 0
            cm[comp] = "fy" => (fy - decay)
        else
            cm[comp] = "fy" => fy + (decay)
        end
    end
end

function rpc!(vm::VultaModifier)
    mods::String = find_client(vm)
    [push!(mod, join(cm.changes)) for mod in values(vm.c[:Session].peers[mods])]
    deleteat!(cm.changes, 1:length(cm.changes))
end

find_client(vm::VultaModifier) = findfirst(x -> getip(c) in keys(x),
                                            vm.c[:Session].peers)

function close(vm)

end

function connect(f::Function, c::Connection, bod::Component{:body}, ip::String,
    width::Int64 = 1280, height::Int64 = 720; tickrate::Int64 = 20)
end

function open(f::Function, c::Connection, width::Int64 = 1280,
    height::Int64 = 720, depth::Int64 = 1000; tickrate::Int64 = 20)
    throw!("3D has not been implemented")
end

function translate!(cm::VultaModifier{Vec2}, comp::Component{:circle}, v::Vec2)
    cm[comp] = "cx" => v.x; cm[comp] = "cy" => v.y
end

function translate!(cm::VultaModifier{Vec2}, comp::Component{:rect}, v::Vec2)
    cm[comp] = "x" => v.x; cm[comp] = "y" => v.y
end

function is_colliding(vm::VultaModifier{Vec2}, s1::Component{<:Any},
    s2::Component{<:Any})
    s1 = vm.rootc[s1.name]
    s2 = vm.rootc[s2.name]
    s1pos = position(s1); s2pos = position(s2)
    diffx, diffy = abs(s1pos.x - s2pos.x), abs(s1pos.y - s2pos.y)
    if diffy < 5 && diffx < 5
        true
    else
        false
    end
end

position(comp::Component{:circle}) = Vec2(parse(Int64, comp["cx"]),
        parse(Int64, comp["cy"]))
position(comp::Component{<:Any}) = Vec2(parse(Int64, comp["x"]),
                parse(Int64, comp["y"]))

function force!(vm::VultaModifier{Vec2}, s::Component{<:Any}, force::Vec2)
    vm[s] = "fx" => force.x
    vm[s] = "fy" => force.y
end

function spawn!(vm::VultaModifier{Vec2}, s::Component{<:Any},
    v::Vec2 = Vec2(0, 0))

end

function spawn!(vm::VultaModifier{Vec2}, s::Component{:rect}, v::Vec2 = Vec2(0, 0);
    decay::Int64 = 1)
    s["x"] = v.x; s["y"] = v.y; s["fx"] = 0; s["fy"] = 0; s["decay"] = decay
    style!(s, "transition" => 1seconds)
    append!(vm, "vulta-main", s)
end

function spawn!(vm::VultaModifier{Vec2}, s::Component{:circle}, v::Vec2 = Vec2(0, 0);
    decay::Int64 = 1)
    s["cx"] = v.x; s["cy"] = v.y; s["fx"] = 0; s["fy"] = 0; s["decay"] = decay
    style!(s, "transition" => 1seconds)
    append!(vm, "vulta-main", s)
end

export spawn!, translate!, VultaModifier, Vec2, Vec3, force!, is_colliding
end # - module
