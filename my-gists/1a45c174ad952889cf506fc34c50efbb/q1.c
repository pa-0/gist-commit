// download glfw3 from https://www.glfw.org/download and then compile:
// cl.exe -O2 q1.c -Iinclude -link opengl32.lib glu32.lib lib-vc2019\glfw3dll.lib

#define _CRT_SECURE_NO_DEPRECATE
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <assert.h>

#define GLFW_INCLUDE_GLU
#include <GLFW/glfw3.h>

#define MAX_FILE_COUNT 1024
#define MAX_TRIANGLE_COUNT 2048
#define MAX_VERTEX_COUNT 1024
#define MAX_FRAME_COUNT 256
#define ANIMATION_FRAMES_PER_SECOND 10

#define GL_CLAMP_TO_EDGE 0x812F

struct {
    char name[56];
    uint32_t offset;
    uint32_t size;
} pak_files[MAX_FILE_COUNT];

static uint8_t pak_palette[256][3];

static FILE* pak[2];
static int pak_file_count[3];

static int mdl_index;

static GLfloat gl_vertices[MAX_FRAME_COUNT][2*MAX_VERTEX_COUNT][3];
static GLfloat gl_texcoords[2*MAX_VERTEX_COUNT][2];
static GLuint  gl_triangles[MAX_TRIANGLE_COUNT][3];
static GLsizei gl_triangle_count;
static GLsizei gl_vertex_count;
static GLsizei gl_frame_count;

static char anim_name[MAX_FRAME_COUNT][16];
static GLFWwindow* window;

static int load_mdl()
{
    FILE* f = pak[mdl_index < pak_file_count[0] ? 0 : 1];

    struct {
        char id[4];
        int version;
        float scale[3];
        float translate[3];
        float bounding_radius;
        float eye_position[3];
        uint32_t tex_count;
        uint32_t tex_width;
        uint32_t tex_height;
        uint32_t vertex_count;
        uint32_t triangle_count;
        uint32_t frame_count;
        int sync;
        int flags;
        float size;
    } mdl_header;

    fseek(f, pak_files[mdl_index].offset, SEEK_SET);
    fread(&mdl_header, sizeof(mdl_header), 1, f);
    assert(memcmp(mdl_header.id, "IDPO", 4) == 0 && mdl_header.version == 6);

    if (mdl_header.triangle_count < 128) {
        return -1;
    }

    gl_vertex_count = mdl_header.vertex_count;

    for (uint32_t i = 0; i < mdl_header.tex_count; i++) {
        uint32_t group;
        fread(&group, sizeof(group), 1, f);
        assert(group == 0);

        static uint8_t tex[1024*1024];
        assert(mdl_header.tex_width <= 1024 && mdl_header.tex_height <= 1024);
        fread(tex, mdl_header.tex_width * mdl_header.tex_height, 1, f);

        static uint8_t rgb[1024*1024][3];
        for (uint32_t k = 0; k < mdl_header.tex_width * mdl_header.tex_height; k++) {
            rgb[k][0] = pak_palette[tex[k]][0];
            rgb[k][1] = pak_palette[tex[k]][1];
            rgb[k][2] = pak_palette[tex[k]][2];
        }
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, mdl_header.tex_width, mdl_header.tex_height, 0, GL_RGB, GL_UNSIGNED_BYTE, rgb);
    }

    struct { uint32_t seam, s, t; } mdl_texcoord[MAX_VERTEX_COUNT];
    fread(mdl_texcoord, sizeof(*mdl_texcoord), mdl_header.vertex_count, f);

    for (uint32_t i = 0; i < mdl_header.vertex_count; i++) {
        float s = mdl_texcoord[i].s + 0.5f;
        float t = mdl_texcoord[i].t + 0.5f;
        gl_texcoords[i][0] = s / mdl_header.tex_width;
        gl_texcoords[i][1] = t / mdl_header.tex_height;
        gl_texcoords[i + mdl_header.vertex_count][0] = (s + mdl_header.tex_width * (mdl_texcoord[i].seam ? 0.5f : 0.f)) / mdl_header.tex_width;
        gl_texcoords[i + mdl_header.vertex_count][1] = t / mdl_header.tex_height;
    }

    struct { uint32_t frontface, vertex[3]; } mdl_triangles[MAX_TRIANGLE_COUNT];
    fread(mdl_triangles, sizeof(*mdl_triangles), mdl_header.triangle_count, f);

    for (uint32_t i = 0; i < mdl_header.triangle_count; i++) {
         gl_triangles[i][0] = mdl_triangles[i].vertex[0] + (mdl_triangles[i].frontface ? 0 : mdl_header.vertex_count);
         gl_triangles[i][1] = mdl_triangles[i].vertex[1] + (mdl_triangles[i].frontface ? 0 : mdl_header.vertex_count);
         gl_triangles[i][2] = mdl_triangles[i].vertex[2] + (mdl_triangles[i].frontface ? 0 : mdl_header.vertex_count);
    }
    gl_triangle_count = mdl_header.triangle_count;

    typedef struct { uint8_t pos[3], normal; } mdl_vertex;

    for (uint32_t i = 0; i < mdl_header.frame_count; i++) {
        uint32_t group;
        fread(&group, sizeof(group), 1, f);
        assert(group == 0);

        struct { mdl_vertex bbmin, bbmax; char name[16]; } mdl_frame;
        fread(&mdl_frame, sizeof(mdl_frame), 1, f);
        strcpy(anim_name[i], mdl_frame.name);

        mdl_vertex vertices[MAX_VERTEX_COUNT];
        fread(vertices, sizeof(*vertices), mdl_header.vertex_count, f);

        for (uint32_t k = 0; k < mdl_header.vertex_count; k++) {
            gl_vertices[i][k][0] = mdl_header.scale[0] * vertices[k].pos[0] + mdl_header.translate[0];
            gl_vertices[i][k][1] = mdl_header.scale[1] * vertices[k].pos[1] + mdl_header.translate[1];
            gl_vertices[i][k][2] = mdl_header.scale[2] * vertices[k].pos[2] + mdl_header.translate[2];

            gl_vertices[i][k + mdl_header.vertex_count][0] = gl_vertices[i][k][0];
            gl_vertices[i][k + mdl_header.vertex_count][1] = gl_vertices[i][k][1];
            gl_vertices[i][k + mdl_header.vertex_count][2] = gl_vertices[i][k][2];
        }
    }
    gl_frame_count = mdl_header.frame_count;

    return 0;
}

static void next_mdl(int index, int delta)
{
    index = (index + pak_file_count[2]) % pak_file_count[2];
    for (;;) {
        char* name = pak_files[index].name;
        if (strcmp(name + strlen(name) - 4, ".mdl") == 0 && strstr(name, "_") == NULL) {
            mdl_index = index;
            if (load_mdl() == 0) {
                printf("MDL file: [%d] %s\n", index, name);
                glfwSetTime(0);
                break;
            }
        }
        index = (index + delta + pak_file_count[2]) % pak_file_count[2];
    }
}

static void read_palette()
{
    for (int i = 0; i < pak_file_count[2]; i++) {
        if (strcmp(pak_files[i].name, "gfx/palette.lmp") == 0) {
            FILE* f = pak[i < pak_file_count[0] ? 0 : 1];
            fseek(f, pak_files[i].offset, SEEK_SET);
            fread(pak_palette, sizeof(pak_palette), 1, f);
            break;
        }
    }
}

static void on_key(GLFWwindow* window, int key, int scancode, int action, int mods)
{
    if (key == GLFW_KEY_RIGHT && action == GLFW_PRESS)
    {
        next_mdl(mdl_index + 1, 1);
    }
    else if (key == GLFW_KEY_LEFT && action == GLFW_PRESS)
    {
        next_mdl(mdl_index - 1, -1);
    }
}

int main(int argc, char* argv[])
{
    pak[0] = fopen("C:/Program Files (x86)/Steam/steamapps/common/Quake/id1/PAK0.PAK", "rb");
    if (!pak[0]) {
        fprintf(stderr, "PAK0 file not found!\n");
        return -1;
    }
    pak[1] = fopen("C:/Program Files (x86)/Steam/steamapps/common/Quake/id1/PAK1.PAK", "rb");
    if (!pak[1]) {
        fprintf(stderr, "PAK1 file not found!\n");
        return -1;
    }

    int count = 0;
    for (int i = 0; i < 2; i++) {
        struct { char id[4]; uint32_t offset; uint32_t size; } pak_header;
        fread(&pak_header, sizeof(pak_header), 1, pak[i]);
        if (memcmp(pak_header.id, "PACK", 4) != 0) {
            fprintf(stderr, "Bad PAK file!\n");
            return -1;
        }
        fseek(pak[i], pak_header.offset, SEEK_SET);
        fread(pak_files + count, pak_header.size, 1, pak[i]);
        pak_file_count[i] = pak_header.size / sizeof(pak_files[0]);
        count += pak_file_count[i];
    }
    pak_file_count[2] = count;

    read_palette();

    glfwInit();
    window = glfwCreateWindow(640, 480, "q1", NULL, NULL);
    glfwMakeContextCurrent(window);
    glfwSetKeyCallback(window, on_key);

    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);

    glEnable(GL_TEXTURE_2D);
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);

    next_mdl(0, 1);

    double time = glfwGetTime();

    while (!glfwWindowShouldClose(window))
    {
        glfwPollEvents();

        double time = glfwGetTime();
        double angle = fmod(-180 + time * 360 / 5, 360);

        double anim = time * ANIMATION_FRAMES_PER_SECOND;
        float anim_lerp = (float)fmod(anim, 1.);
        int frame = (int)anim % gl_frame_count;
        int frame_next = (frame + 1) % gl_frame_count;

        char title[256];
        snprintf(title, sizeof(title), "q1 - %s - %s", pak_files[mdl_index].name, anim_name[frame]);
        glfwSetWindowTitle(window, title);

        int w, h;
        glfwGetWindowSize(window, &w, &h);
        glViewport(0, 0, w, h);

        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        gluPerspective(60.f, (float)w / h, 0.1f, 1000.f);

        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glTranslated(0, 0, -90);
        glRotated(angle, 0, 1, 0);
        glRotated(-90, 1, 0, 0);
        glTranslated(0, 0, -10.f);

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glTexCoordPointer(2, GL_FLOAT, sizeof(*gl_texcoords), gl_texcoords);
        static GLfloat vertices[2 * MAX_VERTEX_COUNT][3];
        for (size_t i = 0; i < 2 * gl_vertex_count; i++) {
            vertices[i][0] = gl_vertices[frame][i][0] * (1.0f - anim_lerp) + gl_vertices[frame_next][i][0] * anim_lerp;
            vertices[i][1] = gl_vertices[frame][i][1] * (1.0f - anim_lerp) + gl_vertices[frame_next][i][1] * anim_lerp;
            vertices[i][2] = gl_vertices[frame][i][2] * (1.0f - anim_lerp) + gl_vertices[frame_next][i][2] * anim_lerp;
        }

        glVertexPointer(3, GL_FLOAT, sizeof(*vertices), vertices);
        glDrawElements(GL_TRIANGLES, gl_triangle_count * 3, GL_UNSIGNED_INT, gl_triangles);

        glfwSwapBuffers(window);
    }
}
