tagname="0.0.1" &&
docker build -t veronicaobute/hls4ml_yolo:$tagname .
f
tagname="0.0.1" &&
sudo docker build -t veronicaobute/hls4ml_yolo:$tagname .

docker run -p 8000:8000 -v "./:/home/jovyan/work" veronicaobute/hls4ml_yolo:$tagname


tagname="0.0.1" &&
docker build -t veronicaobute/part9_YOLO_frame_grabbers:$tagname .


pip freeze > requirments.txt