# 啟動環境
up: down
	docker-compose -p lottery_web up

# 關閉環境
down:
	docker-compose -p lottery_web down

# 進入 container 的 bash
bash:
	docker-compose -p lottery_web exec ${t} bash

# 重新 build 環境
build:
	docker-compose -p lottery_web build

logs:
	docker-compose -p lottery_web logs -f
