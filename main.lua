function love.load()
   kb = love.keyboard
   gr = love.graphics
   width, height = gr.getDimensions()
   
   loose = false
   pause = false
   --map
   --es de 600 * 400 = 240.000
   --la cuadrícula es de 40*40 y tendrá 240.000/(40*40)=150 mosaicos

   map ={}
   map.cuadr = 20

   --time
   time=0
   delay=0.15
   
   --char
   snake = {}
   snake.head = {x = 280, y = 160}
   snake.dim = {w = 20 ,h = 20}
   snake.body = {} --array
   snake.hdg = "down"  --0 down, 1 up, 2 right, 3 left
   snake.dir = "down"  --0 down, 1 up, 2 right, 3 left
   snake.lv = 1
   score = 1 
   table.insert(snake.body, snake.lv)
   snake.body[snake.lv] = {x = snake.head.x, y = snake.head.y - snake.dim.h}

   --food
   food = {}
   food.pos = {x = 40, y = 120}
   food.dim = {w = 20, h = 20}
   food.eaten = false
end

function ate(snake, food)
   if food.pos.x == snake.head.x and
      food.pos.y == snake.head.y then
      food.eaten = true
      grow(snake)
   else
      food.eaten = false
   end
end

function grow(snake)
   snake.lv = snake.lv + 1
   table.insert(snake.body, 1)
   snake.body[snake.lv] = {x = snake.body[snake.lv - 1].x , 
                           y = snake.body[snake.lv - 1].x }
   score = score + 1
end

function direction(snake)
   if snake.hdg == "up" then
      snake.head.y = snake.head.y - map.cuadr
      snake.dir = "up"
   end

   if snake.hdg == "down" then
      snake.head.y = snake.head.y + map.cuadr
      snake.dir = "down"
   end

   if snake.hdg == "right" then
      snake.head.x = snake.head.x + map.cuadr
      snake.dir = "right"
   end

   if snake.hdg == "left" then
      snake.head.x = snake.head.x - map.cuadr
      snake.dir = "left"
   end
end

function move(snake)
   for i = #snake.body, 2, -1 do -- #arreglo
      snake.body[i].x = snake.body[i-1].x
      snake.body[i].y = snake.body[i-1].y
   end
   snake.body[1].x = snake.head.x
   snake.body[1].y = snake.head.y
end

function randomFood(snake, food)
   local aux = math.floor(love.math.random(0,width)/20)
   if aux % 20 ~= 0 then
      aux = aux*20
   end

   food.pos.x = aux

   local aux = math.floor(love.math.random(0,height)/20)
   if aux % 20 ~= 0 then
      aux = aux*20
   end

   food.pos.y = aux

   print(food.pos.x ..", ".. food.pos.y)
end

function colision(snake)
   for i,v in ipairs(snake.body) do
      if snake.body[i].x == snake.head.x
         and snake.body[i].y == snake.head.y then
         return true
      end
   end
   return false
end

function mirror(head)
   if head.x < 0 then
      head.x = width - 20
   elseif head.y < 0 then
      head.y = height - 20
   end

   if head.x == width then
      head.x = 0
   elseif head.y == height then
      head.y = 0
   end
end

function gOver(snake)
   snake.head = {x = 280, y = 160}
   snake.body = {} --array
   snake.hdg = "down"  --0 down, 1 up, 2 right, 3 left
   snake.dir = "down"  --0 down, 1 up, 2 right, 3 left
   snake.lv = 1 
   table.insert(snake.body, snake.lv)
   snake.body[snake.lv] = {x = snake.head.x, y = snake.head.y - snake.dim.h}
   loose = true
end

function love.update(dt)
   --functions
   if not loose then
      time = time + dt
      if time > delay then
         time = 0
         ate(snake, food)
         move(snake)
         direction(snake)
         if food.eaten then
            print("yummm")
            randomFood(snake,food)
            food.eaten = false
         end
         if colision(snake) and not food.eaten then
            gOver(snake)
         end
         mirror(snake.head)
      end
      if kb.isDown("up") and (snake.hdg and snake.dir ~= "down") then
         snake.hdg = "up"
      end
      if kb.isDown("down") and (snake.hdg and snake.dir ~= "up") then
         snake.hdg = "down"
      end
      if kb.isDown("right") and (snake.hdg and snake.dir ~= "left") then
         snake.hdg = "right"
      end
      if kb.isDown("left") and (snake.hdg and snake.dir ~= "right") then
         snake.hdg = "left"
      end
   else
      if kb.isDown("r") then
         loose = false
         score = 1
      end
   end
end

function love.draw()
   --body
-- gr.setColor(255,255,255,255)
-- gr.printf("Head: "..snake.head.x..", "..snake.head.y, 0, 0, 100, "left")
   gr.setColor(255,255,255,255)
   gr.rectangle("fill", snake.head.x, snake.head.y, snake.dim.w, snake.dim.h)
   for i,v in ipairs(snake.body) do
      gr.setColor(255,255,255,255)
      gr.rectangle("fill", snake.body[i].x, snake.body[i].y, snake.dim.w, snake.dim.h)
      gr.setColor(0,0,0,255)
--    gr.printf(i, snake.body[i].x, snake.body[i].y,20,"center")
--    gr.setColor(255,255,255,255) --blanco
--    gr.printf(i..": "..snake.body[i].x..", "..snake.body[i].y, 0, 12*i, 100, "left")
   end

   --head
   gr.setColor(255,0,0,255)
   gr.rectangle("line", snake.head.x, snake.head.y, snake.dim.w, snake.dim.h)

   --food
   gr.setColor(0,255,0,255) --verde
   gr.rectangle("fill", food.pos.x, food.pos.y, food.dim.w, food.dim.h)
   
   gr.setColor(25,55,155,255)
   if loose then
      gr.printf("GAME OVER!!, press R to restart, Score: "..score,width/2 - 100,0,200,"left")
   end
-- gr.printf(#snake.body,120,60,20,"right")
end
