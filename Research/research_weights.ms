gc()
clearlistener()
struct mdx800 ( file, stream, seqs, glbs, mtls, texs, geos, geoa, allObjects )
mdx = mdx800()

Warcraft_III_Helpers.GetSEQS mdx
Warcraft_III_Helpers.GetGEOA mdx

Warcraft_III_Helpers.GetObjects mdx

theMesh = getNodeByName "Anduin_Low"

weights = Warcraft_III_Helpers.GetWeights theMesh mdx

for w in weights.matrices do print w
for w in weights.mtgc do print w
for w in weights.gndx do print w
    