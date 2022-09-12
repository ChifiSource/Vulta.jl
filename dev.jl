using Pkg; Pkg.activate(".")
using Toolips
using Revise
using Vulta

IP = "127.0.0.1"
PORT = 8000
VultaServer = Vulta.start(IP, PORT)
