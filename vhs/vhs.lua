local scx, scy = guiGetScreenSize()
local myScreenSource = dxCreateScreenSource(scx, scy)
local vhsShader = dxCreateShader( "vhs.fx" )
function processVHSEffect(Src) 
    if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused( mx, my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
    local prop = { propX, propY }
	dxSetShaderValue( vhsShader, "Tex0", Src )
	--dxSetShaderValue( vhsShader, "TEX0SIZE", mx,my )
	dxDrawImage( 0, 0, mx,my, vhsShader )
	return newRT
end

addEventHandler( "onClientRender", root,function() 
    RTPool.frameStart()			
    -- Update screen
    dxUpdateScreenSource( myScreenSource, true )

    -- Start with screen
    local current = myScreenSource

    current = processVHSEffect(current) 

    -- When we're done, turn the render target back to default
    dxSetRenderTarget()

    dxDrawImage( 0, 0, scx, scy, current, 0, 0, 0, col )
end)