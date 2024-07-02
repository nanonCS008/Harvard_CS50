--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The BattleSprite class handles the Texture of the Pokemon when in Battle
]]

BattleSprite = Class{}

function BattleSprite:init(x, y, texture)
    self.texture = texture
    self.x = x
    self.y = y
    -- The alpha of the texture can be controlled. Used for alpha blinking
    self.alpha = 255/255
    -- If true, every pixel of the texture will be set to white. Used for white blinking
    self.is_blinking = false

    -- Define a shader that can turn a texture completely white on request.
    -- The same effect cannot be achieved by using love.graphics.setBlendMode or love.graphics.setColor
    -- A shader is code that runs on the graphics card. A fragment (pixel) shader defines the color of each pixel.
    -- LOVE2D uses OpenGL and a slightly modified version of the GLSL shading language.
    -- The shader contains the function effect() that is called for every pixel of the drawn objects.
    -- The return value will be the color of the pixel.
    -- color: The drawing color set with love.graphics.setColor.
    -- tex: The texture of the image being drawn. texcoord: The normalized location inside the texture
    -- screen_coords: Coordinates of the pixel on the screen (not normalized).
    -- With the function send() a variable marked as 'extern' can be set to a value that is sent from the CPU to the GPU.
    -- The function Texel() returns the pixelcolor of the texture at the specified coordinates.
    self.shader_white = love.graphics.newShader([[
        extern float white_factor;

        vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
        {
            vec4 outputcolor = Texel(tex, texcoord) * vcolor;
            outputcolor.rgb += vec3(white_factor);
            return outputcolor;
        }
    ]])
end

function BattleSprite:render()
    love.graphics.setColor(255/255, 255/255, 255/255, self.alpha)

    -- apply shader
    love.graphics.setShader(self.shader_white)
    self.shader_white:send('white_factor', self.is_blinking and 1 or 0)

    love.graphics.draw(gTextures[self.texture], self.x, self.y)

    -- reset shader
    love.graphics.setShader()
end
