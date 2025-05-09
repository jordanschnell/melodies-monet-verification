begin
;
START_TIME=getenv("START_TIME")
;
f=addfile("test5.airnow."+START_TIME+".nc","w")
;
siteid=f->siteid
longitude=f->longitude
;
westoreastof97=siteid
;
westoreastof97 = where(longitude .le. -97.0,"west","east")
;
f->westoreastof97=westoreastof97
;
end
