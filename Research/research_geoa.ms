for t in WC3_MDX.TAGS do print t
for t in WC3_MDX2.TAGS do print t

for geoa in WC3_MDX.GEOA do 
(
    --if ( geoa.GeoId == 4 ) then 
    (
    format "Size: %\n" geoa.size
    format "Opacity: %\n" geoa.Opacity
    format "Color: %\n" geoa.Color
    format "Geo ID: %\n" geoa.GeoId
    format "Type: %\n" geoa.type
    
    for i=1 to geoa.kgao.numPts do
        format "KGAO %\n" geoa.kgao.KG[i]
        
        format "\n"
    )
)

for geoa in WC3_MDX2.GEOA do 
(
    --if ( geoa.GeoId == 4 ) then 
    (
    format "Size: %\n" geoa.size
    format "Opacity: %\n" geoa.Opacity
    format "Color: %\n" geoa.Color
    format "Geo ID: %\n" geoa.GeoId
    format "Type: %\n" geoa.type
    
    for i=1 to geoa.kgao.numPts do
        format "KGAO %\n" geoa.kgao.KG[i]
        
        format "\n"
    )
)



--theMesh = $

struct mdx800 ( file, stream, seqs, glbs, mtls, texs, geos, geoa, allObjects )
mdx = mdx800()

seqs_frames = #(0)
for s in mdx.SEQS do append seqs_frames  ( GriffonStudios_Helpers.RoundToFrame s.startframe )

   
visController = GetVisController theMesh

frames = #()

for key in visController.keys do append frames ( key.time as integer / TicksPerFrame )

for f in seqs_frames do appendIfUnique frames f
                
frames = sort frames


for f in frames do
(
    at time f print theMesh.Visibility
)

