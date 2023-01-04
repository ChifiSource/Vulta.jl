module Vulta
using Toolips
using ToolipsSession
using ToolipsSVG

include("PositionVecttors.jl")

mutable struct VultaCore <: Toolips.ServerExtension
    type::Symbol
    peers::Dict{String, Servable}
    deltas::Dict{String, Int64}
    function VultaCore()
        new(:connection, Dict{String, Servable}())
    end
end

function open(f::Function, c::Connection, bod::Component{:body},
    width::Int64 = 1280, height::Int64 = 720; tickrate::Int64 = 100)
    open_rpc!(c, getip(c), tickrate = tickrate)
    push!(c[:VultaCore].peers,
     getip(c) => Dict{String, Servable}()))
     delta::Int64 = 0
     push!(c[:VultaCore].deltas, getip(c) => delta)
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

function open(f::Function, c::Connection, width::Int64 = 1280,
    height::Int64 = 720, depth::Int64 = 1000; tickrate::Int64 = 20)
    throw!("3D has not been implemented")
end

function join()

function initialize(f::Function, c::Connection)
    if delta(c) == 1
        f(vm)
    end
end

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



export spawn!, translate!, VultaModifier, Vec2, Vec3, force!, is_colliding, initialize
end # - module
