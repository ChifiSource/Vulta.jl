module Vulta
using Toolips
using ToolipsSession
import ToolipsSession: AbstractComponentModifier
using ToolipsSVG

include("PositionVectors.jl")

mutable struct VultaCore{D <: VultaVector} <: Toolips.ServerExtension
    pages::Dict{String, Vector{Pair{Component{<:Any}, D}}}
    delta::Float64
    function VultaCore(d::Symbol = :2D)
        vec = Vec2
        if d == :3D
            vec = Vec3
        end
        new{vec}(Dict{String, Vector{Pair{Component{<:Any}, D}}}())
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
