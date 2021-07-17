.POSIX:

# User Variables
IN_WIDTH=1600
IN_HEIGHT=900
CHANNELS=4
OUT_WIDTH=${IN_WIDTH}
OUT_HEIGHT=${IN_HEIGHT}
RATE=24
FRAME=0
INDEX=0
LENGTH=1

IMAGE_FILE=image.png
FRAMES_DIR=frames
VIDEO_FILE=video.mp4

REPEAT_VIDEO=0

# Core Variables
CC=gcc
CFLAGS=-Wall
LIBS=-lm
SRC=*.c
OBJS=*.o
INCLUDES=*.h
EXE=draw-xy.exe

PIXEL_FORMAT=rgba
ifeq ($(CHANNELS),1)
	PIXEL_FORMAT=gray
else ifeq ($(CHANNELS),2)
	PIXEL_FORMAT=ya8
else ifeq ($(CHANNELS),3)
	PIXEL_FORMAT=rgb24
else ifeq ($(CHANNELS),4)
	PIXEL_FORMAT=rgba
endif

FFMPEG=ffmpeg -hide_banner -loglevel error

PERCENT=%

# User Targets
image: install
	./${EXE} -w ${IN_WIDTH} -h ${IN_HEIGHT} -c ${CHANNELS} -r ${RATE} -f ${FRAME} -i ${INDEX} \
		| ${FFMPEG} -f rawvideo -pixel_format ${PIXEL_FORMAT} -video_size "${IN_WIDTH}"x"${IN_HEIGHT}" -i - -vf scale="${OUT_WIDTH}:${OUT_HEIGHT}" -y "${IMAGE_FILE}"

frames: install
	${eval LENGTH:=${RATE}}
	rm -rf ${FRAMES_DIR}
	mkdir -p ${FRAMES_DIR}
	index=${INDEX}; while [ $$index -lt ${LENGTH} ]; do\
		./${EXE} -w ${IN_WIDTH} -h ${IN_HEIGHT} -c ${CHANNELS} -r ${RATE} -f $$(((${FRAME}+$$index)${PERCENT}${RATE})) -i $$((${INDEX}+$$index)) \
			| ${FFMPEG} -f rawvideo -pixel_format ${PIXEL_FORMAT} -video_size "${IN_WIDTH}"x"${IN_HEIGHT}" -i - -vf scale="${OUT_WIDTH}:${OUT_HEIGHT}" -y "${FRAMES_DIR}/$$(printf "%08d.png" $$(($$index-${INDEX})))"; \
		index=$$(($$index+1)); \
		echo "Index + Frame Done: $$index / ${LENGTH}"; \
	done

video-setup:
	${eval VIDEO_TMP_FILE=${shell mktemp}}
	${eval LENGTH:=${RATE}}
	${eval VIDEO_TMP_DIR=${shell mktemp -d}}
	${eval FRAMES_DIR=${VIDEO_TMP_DIR}}

video: video-setup frames
	${FFMPEG} -framerate ${RATE} -i "${VIDEO_TMP_DIR}/%08d.png" -c:v libx264rgb -crf 4 -y -f mp4 "${VIDEO_TMP_FILE}"
	rm -rf "${VIDEO_TMP_DIR}"
	if [ ${REPEAT_VIDEO} -gt 0 ]; then \
		repeatfile=$$(mktemp); \
		for r in {1..${REPEAT_VIDEO}}; do \
			echo "file '${VIDEO_TMP_FILE}'" >> "$$repeatfile"; \
		done; \
		${FFMPEG} -f concat -safe 0 -i "$$repeatfile" -c copy -y "${VIDEO_FILE}"; \
		rm "$$repeatfile" "${VIDEO_TMP_FILE}"; \
	else \
		mv "${VIDEO_TMP_FILE}" "${VIDEO_FILE}"; \
	fi

# Core Targets
${OBJS}: ${SRC} ${INCLUDES}
	${CC} ${SRC} ${CFLAGS} ${LIBS} -c

install: ${OBJS}
	${CC} ${CFLAGS} -o ${EXE} ${OBJS} ${LIBS}

clean:
	rm -rf ${OBJS} ${EXE}