module Vulta
using Toolips
using ToolipsSession
import ToolipsSession: AbstractComponentModifier
using ToolipsSVG

include("PositionVectors.jl")

mutable struct VultaCore <: Toolips.ServerExtension
    type::Symbol
    peers::Dict{String, Dict{String, Servable}}
    deltas::Dict{String, Int64}
    fields::Dict{String, Dict{Servable, VultaVector}}
    function VultaCore()
        new(:connection, Dict{String, Servable}(), Dict{String, Int64}(),
        Dict{String, Dict{Servable, VultaVector}}())
    end
end

function initialize(f::Function, c::Connection, bod::Component{:body},
    width::Int64 = 1280, height::Int64 = 720; tickrate::Int64 = 50)
    push!(c[:VultaCore].peers, getip(c) * "rpc" => Dict{String, Servable}())
     push!(c[:VultaCore].deltas, getip(c) * "rpc" => 0)
     push!(c[:VultaCore].fields, getip(c) => Dict{Servable, VultaVector}())
    open_rpc!(c, getip(c) * "rpc", tickrate = tickrate) do cm::ComponentModifier
        c[:VultaCore].deltas[getip(c) * "rpc"] += 1
        [begin
        component = cm[comp[1]]
        vec = position(component)
        c[:VultaCore].fields[getip(c)][comp[1]] = vec
        end for comp in c[:VultaCore].fields[getip(c)]]
        [force(cm, comp) for comp in values(cm.rootc)]
        f(cm)
    end
    wind = svg("vulta-main", width = width, height = height)
    push!(bod, wind)
    style!(wind, "padding" => 0px, "position" => "absolute")
    write!(c, bod)
end

function join(c::Connection, host::String,
    bod::Component{:body}, width::Int64 = 1280,
    height::Int64 = 720; tickrate::Int64 = 100)
    wind = svg("vulta-main", width = width, height = height)
    push!(bod, wind)
    style!(wind, "padding" => 0px, "position" => "absolute")
    first = true
    join_rpc!(c, host, tickrate = tickrate) do cm::ComponentModifier
        client_name = replace(find_client(c), "rpc" => "")
        for comp in c[:VultaCore].fields[client_name]
            spawn!(c, cm, comp[1], comp[2])
        end
    end
    write!(c, bod)
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
    end
    if fy != 0
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
export initializing, delta, hard_force!
export VultaCore
end # - module
