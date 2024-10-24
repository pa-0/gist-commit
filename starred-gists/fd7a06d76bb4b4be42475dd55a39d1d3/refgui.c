// Simple reference for what I think is a sane approach to structuring GUIs.
// Platform code is cleanly separated from the GUI code.
// Win32 backend (the OpenGL code is unused)
// Easy to port to other platforms - X11, SDL, OpenGL...

#include <Windows.h>
#include <windowsx.h>  // GET_X_LPARAM(), GET_Y_LPARAM()
#include <mshtmcid.h>  // IDM_CUT, IDM_COPY etc

#include <GL/gl.h>
#include <GL/glext.h>
#include <GL/wglext.h>

#include <assert.h>
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>

#define DEFINE_STRUCT(name) typedef struct _##name name; struct _##name
#define NORETURN __declspec(noreturn)
#define UNUSED(name) ((void) (name))
#define ARRAY_COUNT(a) ((int) (sizeof (a) / sizeof (a)[0]))


static inline int32_t minimum_int32(int32_t a, int32_t b) { return a < b ? a : b; }
static inline int32_t maximum_int32(int32_t a, int32_t b) { return a > b ? a : b; }

// C11 standard currently not supported, so not trying to use _Generic
#define minimum(X, Y) ((X) < (Y) ? (X) : (Y))
#define maximum(X, Y) ((X) > (Y) ? (X) : (Y))



//////////////////////////////////////////////////////////////////
// Logging
//////////////////////////////////////////////////////////////////


void msg_fv(const char *fmt, va_list ap)
{
        vfprintf(stderr, fmt, ap);
        fprintf(stderr, "\n");
}

void msg_f(const char *fmt, ...)
{
        va_list ap;
        va_start(ap, fmt);
        msg_fv(fmt, ap);
        va_end(ap);
}

NORETURN void fatal_fv(const char *fmt, va_list ap)
{
        msg_fv(fmt, ap);
        abort();
}

NORETURN void fatal_f(const char *fmt, ...)
{
        va_list ap;
        va_start(ap, fmt);
        fatal_fv(fmt, ap);
        //va_end(ap);
}


//////////////////////////////////////////////////////////////////
// Fonts
//////////////////////////////////////////////////////////////////

DEFINE_STRUCT(Texture_8bit)
{
        uint8_t buffer[1024][1024];
};

DEFINE_STRUCT(Cached_Glyph)
{
        uint32_t codepoint;

        uint8_t font_size;

        int16_t x;
        int16_t y;
        int16_t w;
        int16_t h;

        int16_t dx;
        int16_t dy;
        int16_t advance;

        Texture_8bit *texture;
};

DEFINE_STRUCT(Font_Atlas)
{
        // For now, a single texture and a fixed number of cached glyphs...
        Texture_8bit texture;

        // Far too simplistic allocation model.
        int16_t tex_alloc_x;
        int16_t tex_alloc_y;
        int16_t tex_alloc_max_h;  // maximum height of the current row.

        Cached_Glyph cached_glyphs[4096];
        int num_cached_glyphs;

        // Increases when there was a change.
        uint32_t generation;
};


static Cached_Glyph *lookup_cached_glyph(Font_Atlas *atlas, uint32_t codepoint, uint8_t font_size)
{
        for (int i = 0; i < atlas->num_cached_glyphs; i++)
        {
                Cached_Glyph *glyph = atlas->cached_glyphs + i;
                if (glyph->codepoint == codepoint && glyph->font_size == font_size)
                        return glyph;
        }
        return NULL;
}

static Cached_Glyph *alloc_cached_glyph(Font_Atlas *atlas, uint32_t codepoint, uint8_t font_size,
        int16_t glyph_w, int16_t glyph_h)
{
        if (atlas->num_cached_glyphs == ARRAY_COUNT(atlas->cached_glyphs))
                return NULL;

        int texture_h = ARRAY_COUNT(atlas->texture.buffer);
        int texture_w = ARRAY_COUNT(atlas->texture.buffer[0]);

        if (atlas->tex_alloc_x + glyph_w + 2 > texture_w)
        {
                atlas->tex_alloc_x = 0;
                atlas->tex_alloc_y = atlas->tex_alloc_y + atlas->tex_alloc_max_h;
                atlas->tex_alloc_max_h = 0;
        }

        if (atlas->tex_alloc_y + glyph_h + 2 > texture_h)
        {
                return NULL;
        }

        Cached_Glyph *glyph = atlas->cached_glyphs + atlas->num_cached_glyphs++;

        glyph->codepoint = codepoint;
        glyph->font_size = font_size;
        glyph->texture = &atlas->texture;
        glyph->x = atlas->tex_alloc_x + 1;
        glyph->y = atlas->tex_alloc_y + 1;
        glyph->w = glyph_w;
        glyph->h = glyph_h;

        atlas->tex_alloc_x += glyph_w + 1;
        if (atlas->tex_alloc_max_h < glyph_h)
                atlas->tex_alloc_max_h = glyph_h;

        ++ atlas->generation;

        return glyph;
}



#include <ft2build.h>
#include FT_FREETYPE_H

DEFINE_STRUCT(Font_Face)
{
        const char *filepath;

	uint8_t current_size;
        uint8_t current_nominal_height;

        FT_Face ft_face; //XXX
};

static FT_Library ft_library;


static void setup_freetype(void)
{
        FT_Error error;

        error = FT_Init_FreeType(&ft_library);
        if (error)
        {
                fatal_f("FT_Init_FreeType() failed");
        }
}

static void teardown_freetype(void)
{
        // Anything to do?
}


static void set_font_size(Font_Face *font, uint8_t font_size)
{
	FT_Error error = FT_Set_Pixel_Sizes(font->ft_face, font_size, 0);

	if (error)
	{
		fatal_f("FT_Set_Pixel_Sizes() failed"); //TODO
	}

	font->current_size = font_size;
	//font->current_nominal_height = (uint8_t)(font->ft_face->height / 64);
	//XXX
	font->current_nominal_height = (uint8_t)((font->ft_face->height / 64) * font_size * 6/5 / (font->ft_face->units_per_EM / 64));
}

static void load_font(Font_Face *font, const char *filepath)
{
        font->filepath = filepath; //XXX

        FT_Error error = FT_New_Face(ft_library, filepath, 0, &font->ft_face);

        if (error)
        {
                // TODO
                if (error == FT_Err_Unknown_File_Format)
                {
                        fatal_f("FT_New_Face() failed" ": Unknown file format");
                }
                else
                {
                        fatal_f("FT_New_Face() failed");
                }
        }

	set_font_size(font, 10); // necessary?
}

static Cached_Glyph *get_glyph(Font_Atlas *atlas, Font_Face *font, uint32_t codepoint)
{
	uint8_t font_size = font->current_size;
	FT_Face ft_face = font->ft_face;

        Cached_Glyph *glyph = lookup_cached_glyph(atlas, codepoint, font_size);

        if (glyph)
                return glyph;

        FT_UInt glyph_index = FT_Get_Char_Index(ft_face, codepoint);

        // TODO: handle glyph_index==0

        FT_Error error = FT_Load_Glyph(ft_face, glyph_index, FT_LOAD_DEFAULT);

        if (error)
        {
                fatal_f("FT_Load_Glyph() failed");
        }

        error = FT_Render_Glyph(ft_face->glyph, FT_RENDER_MODE_NORMAL);

        if (error)
        {
                fatal_f("FT_Render_Glyph() failed");
        }


        FT_GlyphSlot slot = ft_face->glyph;

        glyph = alloc_cached_glyph(atlas, codepoint, font_size, /*(int16_t) slot->bitmap_left,*/ (int16_t) slot->bitmap.width, (int16_t) slot->bitmap.rows);
        glyph->dx = (int16_t) (slot->metrics.horiBearingX / 64);
        glyph->dy = (int16_t) (- slot->metrics.horiBearingY / 64);
        glyph->advance = (int16_t) (slot->metrics.horiAdvance / 64);
	//printf("Metrics %c: horiBearingY=%d\n", codepoint, -glyph->dy);
        
        Texture_8bit *tex = &atlas->texture;
        int atlas_left = glyph->x;
        int atlas_top = glyph->y;
        int atlas_right = glyph->x + glyph->w;
        int atlas_bottom = glyph->y + glyph->h;

        int bitmap_index = 0; //???

        for (int i = atlas_top; i < atlas_bottom; i++)
        {
                for (int j = atlas_left, x = 0; j < atlas_right; j++, x++)
                {
                        tex->buffer[i][j] = slot->bitmap.buffer[bitmap_index + x];
                        //printf("%c", tex->buffer[i][j] > 64 ? 'X' : ' ');
                }
                bitmap_index += slot->bitmap.pitch;
                //printf("\n");
        }

        return glyph;
}


//////////////////////////////////////////////////////////////////
// Rendering
//////////////////////////////////////////////////////////////////

DEFINE_STRUCT(Ui_Pos)
{
        int32_t x;
        int32_t y;
};

DEFINE_STRUCT(Ui_String)
{
        const char *buffer;
        int size;
};
#define Ui_String(...) ((Ui_String) { __VA_ARGS__ })

static inline Ui_String ui_string(const char *text)
{
        return (Ui_String) { text, strlen(text) };
}

DEFINE_STRUCT(Text_Layout_Cache)
{
        const char *characters;
        Ui_Pos *positions;
        int size;
};

DEFINE_STRUCT(Render_Quad)
{
        int32_t x;
        int32_t y;
        int32_t w;
        int32_t h;
        int32_t clip_x;
        int32_t clip_y;
        int32_t clip_w;
        int32_t clip_h;
        uint32_t color;
        Ui_String text;
};

DEFINE_STRUCT(Render_Batch)
{
        Render_Batch *next_in_stack;
        Render_Batch *next_in_list;
        Render_Quad quads[128];
        int num_quads;
};



enum
{
        WIN32_RENDERER_MODE_ROUNDRECT,
        WIN32_RENDERER_MODE_FILLRECT,
        WIN32_RENDERER_MODE_BLIT32,
        WIN32_RENDERER_MODE_BLIT64,
        NUM_WIN32_RENDERER_MODES
};

static const char *win32_renderer_mode_string[NUM_WIN32_RENDERER_MODES] = {
        "roundrect",
        "fillrect",
        "blit32",
        "blit64",
};

static int win32_renderer_mode;



//////////////////////////////////////////////////////////////////
// UI
//////////////////////////////////////////////////////////////////

enum
{
        UICOLOR_TITLEBAR,
        UICOLOR_BACKGROUND,
        UICOLOR_HOVER,
        UICOLOR_BORDER,
        UICOLOR_INTERACTING,
        UICOLOR_FONT,
        NUM_UICOLORS,
};

static const char *ui_color_name(int color_index)
{
        switch (color_index)
        {
        case UICOLOR_TITLEBAR: return "titlebar";
        case UICOLOR_BACKGROUND: return "background";
        case UICOLOR_BORDER: return "border";
        case UICOLOR_HOVER: return "hover";
        case UICOLOR_FONT: return "font";
        case UICOLOR_INTERACTING: return "interacting";
        default: assert(0); return "";
        }
}

static uint32_t color_map[NUM_UICOLORS] = {
        RGB(132, 192, 215),
        RGB(130, 176, 180),
        RGB(149, 159, 170),
        RGB(173, 131, 155),
        RGB(70, 151, 215),
        RGB(56, 64, 58),
};


enum
{
        UICURSOR_NORMAL,
        UICURSOR_RESIZE,
        UICURSOR_HAND,
        NUM_UICURSORS,
};


enum
{
        UIKEY_RETURN,
        UIKEY_TAB,
        UIKEY_ESCAPE,
        UIKEY_CURSORUP,
        UIKEY_CURSORDOWN,
        UIKEY_CURSORLEFT,
        UIKEY_CURSORRIGHT,
	UIKEY_HOME,
	UIKEY_END,
        UIKEY_BACKSPACE,
        UIKEY_DELETE,
        UIKEY_SHIFT,
        UIKEY_CONTROL,
        UIKEY_ALT,
	UIKEY_F1,
	UIKEY_F2,
	UIKEY_F3,
	UIKEY_F4,
	UIKEY_F5,
	UIKEY_F6,
	UIKEY_F7,
	UIKEY_F8,
	UIKEY_F9,
	UIKEY_F10,
	UIKEY_F11,
        UIKEY_F12,
        UIKEY_SPACE,
        NUM_UIKEYS
};

enum
{
        UISIDE_LEFT,
        UISIDE_RIGHT,
        UISIDE_TOP,
        UISIDE_BOTTOM,
};


DEFINE_STRUCT(Ui_Rect)
{
        int32_t x;
        int32_t y;
        int32_t w;
        int32_t h;
};
#define Ui_Rect(...) (Ui_Rect) { __VA_ARGS__ }



DEFINE_STRUCT(Ui_Region)
{
        Ui_Region *parent;
        Ui_Region *first_child;
        Ui_Region *last_child;
        Ui_Region *next_sibling;
        Ui_Region *prev_sibling;

        int cursor_kind;
        Ui_Rect rect;
};

void ui_set_parent_region(Ui_Region *child, Ui_Region *parent)
{
        child->parent = parent;
        child->prev_sibling = parent->last_child;
        child->next_sibling = NULL;
        if (parent->last_child)
                parent->last_child->next_sibling = child;
        else
                parent->first_child = child;
        parent->last_child = child;
}

void ui_remove_region(Ui_Region *child)
{
        assert(child->parent);
        if (child->prev_sibling)
                child->prev_sibling->next_sibling = child->next_sibling;
        else
                child->parent->first_child = child->next_sibling;
        if (child->next_sibling)
                child->next_sibling->prev_sibling = child->prev_sibling;
        else
                child->parent->last_child = child->prev_sibling;
        child->parent = NULL;
        child->prev_sibling = NULL;
        child->next_sibling = NULL;
}




DEFINE_STRUCT(Ui)
{
        int initialized;
        int32_t pad_size;  //horizontal + vertical pad amount

        // Window Inputs

        int platform_requested_close;

        int32_t win_x;
        int32_t win_y;
        int32_t win_w;
        int32_t win_h;

        int32_t mouse_x;
        int32_t mouse_y;
        int32_t mouse_last_x;
        int32_t mouse_last_y;
        int32_t mouse_dx;  // convenience shortcut
        int32_t mouse_dy;  // convenience shortcut

        char mousebutton_down;
        char mousebutton_was_down;
        char mousebutton_pressed;  // convenience shortcut
        char mousebutton_released;  // convenience shortcut

        char mousewheel_scrolled_up;
        char mousewheel_scrolled_down;

        unsigned char key_down[NUM_UIKEYS];  // the high-order bit indicates if it is down, and if it is, the lower bits form a repeat count so we can detect repeats.
        unsigned char key_was_down[NUM_UIKEYS];
        char key_pressed[NUM_UIKEYS];  // whether the key was pressed since last time. TODO: better name.

        int have_unicode_input;
        uint32_t unicode_input;

	char paste_input[1024];  // For now, static buffer...
	int paste_input_size;

        // Window Outputs

        int want_close;
        int want_fullscreen;
        int want_cursor_kind;
        int is_animation_active;

        Render_Batch *first_render_batch;
        Render_Batch *last_render_batch;

        // Layout stack. We begin with a rectangular area (probably the window area).
        // Normally each element will split the rectangle in two rectangles by breaking
        // a rect from the left, right, top, or bottom.

        Ui_Rect layout_rect_stack[32];
        int layout_rect_stack_size;

        // Mouse interaction. We define a tree of "Regions" (all rectangular
        // currently) that correspond to GUI elements that are of interest for
        // mouse interaction. "Interaction" basically means mouse grabbing /
        // dragging the hovered region, but it is named more abstractly (touch
        // input?)

        Ui_Region root_region;
        Ui_Region *region_stack;
        Ui_Region *hovered_region;
        Ui_Region *focused_region;

        char is_interacting;  // with hovered_region
        char was_interacting;

        // some helpers so not every average interacting player needs to declare its own store.
        int32_t interacting_start_x;  // mouse_x when interaction started
        int32_t interacting_start_y;  // mouse_y when interaction started
        int32_t interacting_since_start_dx;
        int32_t interacting_since_start_dy;
        Ui_Rect interacting_start_rect;

        // Rendering

        Font_Face font_face;
        Font_Atlas font_atlas;

        Ui_Rect clip_rect;
        char captions[8][2];  // test

        Render_Batch *render_batch_stack;
        Render_Batch render_batch;  // Ui's own render batch
};

// This is only a placeholder for some future exact measuring routine.
int32_t ui_measure_text(Ui *ui, Ui_String string)
{
        UNUSED(ui);
        return 15 * string.size;
}



void ui_layout_text_line(Ui *ui, Ui_String text, int32_t x, int32_t y, int32_t w, Text_Layout_Cache *cache, Ui_Pos *positions_storage)
{
        cache->positions = positions_storage; //XXX
        cache->characters = text.buffer;
        cache->size = text.size;

        int32_t right = x + w;
        UNUSED(right);//TODO

        for (int i = 0; i < text.size; i++)
        {
                uint32_t codepoint = text.buffer[i];
                Cached_Glyph *glyph = get_glyph(&ui->font_atlas, &ui->font_face, codepoint);
                Ui_Pos *pos = cache->positions + i;
                pos->x = x;
		pos->y = y;
                x += glyph->advance;
        }

	// XXX one-past-last position
	cache->positions[text.size] = (Ui_Pos) { x, y };
}






Ui_Rect ui_get_layout_rect(Ui *ui)
{
        return ui->layout_rect_stack[ui->layout_rect_stack_size - 1];
}

Ui_Rect ui_cut_layout_rect(Ui *ui, int cut_side, int32_t size)
{
        Ui_Rect oldrect = ui->layout_rect_stack[ui->layout_rect_stack_size - 1];
        Ui_Rect newrect = oldrect;

        if (cut_side == UISIDE_LEFT)
        {
                if (size > newrect.w)
                        size = newrect.w;

                newrect.w = size;

                oldrect.x += size;
                oldrect.w -= size;
        }
        else if (cut_side == UISIDE_RIGHT)
        {
                if (size > newrect.w)
                        size = newrect.w;

                newrect.x += newrect.w - size;
                newrect.w = size;

                oldrect.w -= size;
        }
        else if (cut_side == UISIDE_TOP)
        {
                if (size > newrect.h)
                        size = newrect.h;

                newrect.h = size;

                oldrect.y += size;
                oldrect.h -= size;
        }
        else if (cut_side == UISIDE_BOTTOM)
        {
                if (size > newrect.h)
                        size = newrect.h;

                newrect.y += newrect.h - size;
                newrect.h = size;

                oldrect.h -= size;
        }

        ui->layout_rect_stack[ui->layout_rect_stack_size - 1] = oldrect;

        return newrect;
}

Ui_Rect ui_push_layout_rect(Ui *ui, Ui_Rect rect)
{
        ui->layout_rect_stack[ui->layout_rect_stack_size++] = rect;
        return rect;
}

Ui_Rect ui_dup_layout_rect(Ui *ui)
{
        return ui_push_layout_rect(ui, ui_get_layout_rect(ui));
}

Ui_Rect ui_pad_rect(Ui *ui, Ui_Rect rect)
{
        int32_t w = minimum_int32(ui->pad_size, rect.w);
        int32_t h = minimum_int32(ui->pad_size, rect.h);
        rect.x += w;
        rect.y += h;
        rect.w -= w;  // XXX should be 2 * w, but that's too much in some places where we shouldn't use padding at all
        rect.h -= h;  // XXX should be 2 * h...
        return rect;
}

void ui_pad_layout_rect(Ui *ui)
{
        Ui_Rect *rect = ui->layout_rect_stack + ui->layout_rect_stack_size - 1;
        *rect = ui_pad_rect(ui, *rect);
}

Ui_Rect ui_push_cut_layout_rect(Ui *ui, int cut_side, int32_t size)
{
        Ui_Rect rect = ui_cut_layout_rect(ui, cut_side, size);
        ui_push_layout_rect(ui, rect);
        return rect;
}

void ui_pop_layout_rect(Ui *ui)
{
        assert(ui->layout_rect_stack_size > 0);
        --ui->layout_rect_stack_size;
}


void ui_add_region(Ui *ui, Ui_Region *region, Ui_Rect rect)
{
        // Intersect region-rect with clip rect.
        Ui_Rect clip_rect = ui->clip_rect;
        int32_t left   = rect.x          > clip_rect.x               ? rect.x : clip_rect.x;
        int32_t right  = rect.x + rect.w < clip_rect.x + clip_rect.w ? rect.x + rect.w : clip_rect.x + clip_rect.w;
        int32_t top    = rect.y          > clip_rect.y               ? rect.y : clip_rect.y;
        int32_t bottom = rect.y + rect.h < clip_rect.y + clip_rect.h ? rect.y + rect.h : clip_rect.y + clip_rect.h;

        Ui_Rect clipped_rect = Ui_Rect(left, top, right - left, bottom - top);

        region->rect = clipped_rect;
        ui_set_parent_region(region, ui->region_stack);
}

void ui_push_region(Ui *ui, Ui_Region *region, Ui_Rect rect)
{
        assert(ui->region_stack);
        ui_add_region(ui, region, rect);
        ui->region_stack = region;
}

void ui_pop_region(Ui *ui)
{
        ui->region_stack = ui->region_stack->parent;
}

Ui_Region *ui_find_region_at(Ui_Region *region, int32_t x, int32_t y)
{
        Ui_Region *candidate = NULL;
        Ui_Rect rect = region->rect;
        if (rect.x <= x && x < rect.x + rect.w
                && rect.y <= y && y < rect.y + rect.h)
        {
                candidate = region;
        }

        for (Ui_Region *child = region->first_child;
                child; child = child->next_sibling)
        {
                Ui_Region *found = ui_find_region_at(child, x, y);
                if (found)
                        candidate = found;
        }

        return candidate;
}


void ui_begin_render_batch(Ui *ui, Render_Batch *batch)
{
        batch->next_in_stack = ui->render_batch_stack;
        ui->render_batch_stack = batch;
        batch->num_quads = 0;
}

void ui_end_render_batch(Ui *ui)
{
        Render_Batch *batch = ui->render_batch_stack;
        ui->render_batch_stack = batch->next_in_stack;
        batch->next_in_stack = NULL;
}

void ui_enable_render_batch(Ui *ui, Render_Batch *batch)
{
        batch->next_in_list = NULL;
        if (ui->first_render_batch)
                ui->last_render_batch->next_in_list = batch;
        else
                ui->first_render_batch = batch;
        ui->last_render_batch = batch;
}

void ui_add_quad(Ui *ui, Ui_Rect rect, int32_t color, Ui_String text)
{
        Render_Batch *batch = ui->render_batch_stack;
        assert(batch->num_quads < ARRAY_COUNT(batch->quads));
        Render_Quad *quad = batch->quads + batch->num_quads++;

        quad->x = rect.x;
        quad->y = rect.y;
        quad->w = rect.w;
        quad->h = rect.h;
        quad->clip_x = ui->clip_rect.x;
        quad->clip_y = ui->clip_rect.y;
        quad->clip_w = ui->clip_rect.w;
        quad->clip_h = ui->clip_rect.h;
        quad->color = color;
        quad->text = text;
}

void ui_add_quad_and_push_region(Ui *ui, Ui_Rect rect, int32_t color, Ui_String text, Ui_Region *region)
{
        ui_add_quad(ui, rect, color, text);
        ui_push_region(ui, region, rect);
}

void ui_add_quad_and_add_region(Ui *ui, Ui_Rect rect, int32_t color, Ui_String text, Ui_Region *region)
{
        ui_add_quad_and_push_region(ui, rect, color, text, region);
        ui_pop_region(ui);
}

void ui_push_clip_rect(Ui *ui, Ui_Rect rect)
{
        ui->clip_rect = rect;  // XXX
}

void ui_pop_clip_rect(Ui *ui)
{
        ui->clip_rect = Ui_Rect(0, 0, 4096, 4096);  //XXX
}



DEFINE_STRUCT(Ui_Layout_Info)
{
        int32_t optimal_width;
        int32_t optimal_height;
        Ui_Rect *out_rect;
};

DEFINE_STRUCT(Ui_Layout)
{
        Ui_Layout_Info *layout_infos;
        int num_layout_infos;
        // output from layout procedure
        int32_t optimal_width;
        int32_t optimal_height;
};

void ui_do_layout_horizontal(Ui *ui, Ui_Layout *layout, Ui_Rect container_rect)
{
        int32_t max_h = 0;
        int32_t max_y = 0;
        int32_t x = 0;
        int32_t y = 0;
        int32_t right = container_rect.w;
        for (int i = 0; i < layout->num_layout_infos; i++)
        {
                Ui_Layout_Info *info = layout->layout_infos + i;
                int32_t w = info->optimal_width;
                int32_t h = info->optimal_height;
                if (x > 0 && x + info->optimal_width > right)
                {
                        x = 0;
                        y += max_h;
                        max_h = 0;
                }
                if (max_h < h)
                        max_h = h;
                if (max_y < y + h)
                        max_y = y + h;
                *info->out_rect = ui_pad_rect(ui, Ui_Rect(container_rect.x + x, container_rect.y + y, w, h));
                x += w;
        }
        layout->optimal_width = container_rect.w;
        layout->optimal_height = max_y - container_rect.y;
}

void ui_do_layout_vertical(Ui *ui, Ui_Layout *layout, Ui_Rect container_rect)
{
        int32_t max_w = 0;
        int32_t max_y = 0;
        int32_t x = 0;
        int32_t y = 0;
        int32_t bottom = container_rect.h;
        for (int i = 0; i < layout->num_layout_infos; i++)
        {
                Ui_Layout_Info *info = layout->layout_infos + i;
                int32_t w = info->optimal_width;
                int32_t h = info->optimal_height;
                if (y > 0 && y + info->optimal_height > bottom)
                {
                        x += max_w;
                        max_w = 0;
                        y = 0;
                }
                if (max_w < w)
                        max_w = w;
                ui_push_layout_rect(ui, Ui_Rect(container_rect.x + x, container_rect.y + y, w, h));
                ui_pad_layout_rect(ui);
                *info->out_rect = ui_get_layout_rect(ui);
                ui_pop_layout_rect(ui);
                y += h;
                if (max_y < y)
                        max_y = y;
        }
        layout->optimal_width = max_w;
        layout->optimal_height = max_y - container_rect.y;
}

DEFINE_STRUCT(Ui_Toplevel_Window)
{
        Ui_Toplevel_Window *prev;
        Ui_Toplevel_Window *next;

        int is_initialized;
        int is_closed;
        int is_moving_window;
        int is_resizing_window;

        Ui_Region container_region;
        Ui_Region titlebar_region;
        Ui_Region border_resize_region;

        Ui_Rect container_rect;
        Ui_Rect old_container_rect;

        int32_t vscroll;  // offsetting the child container.

        char name[128];
        int size;

        // Rendering
        Render_Batch render_batch;
};


void ui_begin_toplevel_window(Ui *ui, Ui_Toplevel_Window *tlw, Ui_Rect initial_rect, const char *text)
{
        int32_t title_h = ui->font_face.current_nominal_height;

        if (!tlw->is_initialized)
        {
                tlw->is_initialized = 1;
                tlw->size = (int)snprintf(tlw->name, sizeof tlw->name, "%s", text);
                tlw->container_rect = initial_rect;

                tlw->titlebar_region.cursor_kind = UICURSOR_HAND;
                tlw->border_resize_region.cursor_kind = UICURSOR_RESIZE;
        }

        // Determine if the mouse is hovering over this window.
        int container_or_child_hovered = 0;
        for (Ui_Region *region = ui->hovered_region;
                region; region = region->parent)
        {
                if (region == &tlw->container_region)
                        container_or_child_hovered = 1;
        }

        if (ui->hovered_region == &tlw->border_resize_region)
        {
            if (ui->mousewheel_scrolled_down)
                tlw->vscroll += 20;
            if (ui->mousewheel_scrolled_up)
            {
                tlw->vscroll -= 20;
                if (tlw->vscroll < 0)
                    tlw->vscroll = 0;
            }
        }
        

        if (tlw->is_moving_window || tlw->is_resizing_window)
        {
                if (tlw->is_moving_window)
                {
                        tlw->container_rect.x += ui->mouse_dx;
                        tlw->container_rect.y += ui->mouse_dy;

                        if (ui->key_pressed[UIKEY_RETURN])
                                tlw->is_closed ^= 1;  //test
                }
                else if (tlw->is_resizing_window)
                {
                        tlw->container_rect.w = maximum(50, tlw->old_container_rect.w + ui->interacting_since_start_dx);
                        tlw->container_rect.h = maximum(50, tlw->old_container_rect.h + ui->interacting_since_start_dy);
                }

                if (ui->key_pressed[UIKEY_ESCAPE])
                {
                        ui->is_interacting = 0; //XXX
                        tlw->container_rect = tlw->old_container_rect;
                }
                if (!ui->is_interacting)
                {
                        tlw->is_moving_window = 0;
                        tlw->is_resizing_window = 0;
                }
        }
        else if (ui->is_interacting)
        {
                if ((ui->key_down[UIKEY_ALT] && container_or_child_hovered) ||
                    (ui->hovered_region == &tlw->titlebar_region))
                {
                        tlw->old_container_rect = tlw->container_rect;
                        tlw->is_moving_window = 1;
                }
                else if (ui->hovered_region == &tlw->border_resize_region)
                {
                        tlw->old_container_rect = tlw->container_rect;
                        tlw->is_resizing_window = 1;
                }
        }

        // Start drawing. (ended in ui_end_toplevel_window())
        ui_begin_render_batch(ui, &tlw->render_batch);  // own render batch.

        // container
        ui_push_layout_rect(ui, tlw->container_rect);
        ui_add_quad_and_push_region(ui, ui_get_layout_rect(ui), color_map[UICOLOR_BACKGROUND], ui_string(""), &tlw->container_region);

        // titlebar
        ui_push_cut_layout_rect(ui, UISIDE_TOP, title_h);
        ui_add_quad_and_add_region(ui, ui_get_layout_rect(ui), color_map[UICOLOR_TITLEBAR], ui_string(text), &tlw->titlebar_region);
        ui_pop_layout_rect(ui);

        // Start child
        ui_dup_layout_rect(ui);
        ui_push_clip_rect(ui, ui_get_layout_rect(ui));
        ui_pad_layout_rect(ui);  // remove a little padding space from all sides
        ui_cut_layout_rect(ui, UISIDE_RIGHT, 30);  // remove even more space from the right (that is covered by resize handle)

        //XXX test implementation of vscroll
        ui->layout_rect_stack[ui->layout_rect_stack_size - 1].y -= tlw->vscroll;
        ui->layout_rect_stack[ui->layout_rect_stack_size - 1].h += tlw->vscroll;
}

void ui_end_toplevel_window(Ui *ui, Ui_Toplevel_Window *tlw)
{
        // End child
        ui_pop_clip_rect(ui);
        ui_pop_layout_rect(ui);

        // a resize handle at right border.
        Ui_Rect container_rect = ui_get_layout_rect(ui);
        Ui_Rect resize_rect = { container_rect.x + container_rect.w - 20, container_rect.y, 40, container_rect.h };
        ui_add_quad_and_add_region(ui, resize_rect, color_map[UICOLOR_BORDER], ui_string(""), &tlw->border_resize_region);

        ui_pop_region(ui);  // container
        ui_pop_layout_rect(ui);  // container
        ui_end_render_batch(ui);
}



DEFINE_STRUCT(Ui_Lineedit)
{
        Ui_Region region;
        char buf[128];
        int size;
        int cursorpos;

	Ui_Pos positions_storage[128]; //XXX
	Text_Layout_Cache text_layout_cache;
};

void ui_do_lineedit(Ui *ui, Ui_Lineedit *line, Ui_Rect rect)
{
	if (ui->key_pressed[UIKEY_CURSORLEFT])
	{
		if (line->cursorpos > 0)
			line->cursorpos -= 1;
		if (ui->key_down[UIKEY_CONTROL])
		{
			while (line->cursorpos > 0 && line->buf[line->cursorpos - 1] > 0x20)
				line->cursorpos -= 1;
		}
        }
        if (ui->key_pressed[UIKEY_CURSORRIGHT])
        {
		if (line->cursorpos < line->size)
			line->cursorpos += 1;
		if (ui->key_down[UIKEY_CONTROL])
		{
			while (line->cursorpos < line->cursorpos && line->buf[line->cursorpos] > 0x20)
				line->cursorpos += 1;
		}
        }
	if (ui->key_pressed[UIKEY_HOME])
	{
		line->cursorpos = 0;
	}
	if (ui->key_pressed[UIKEY_END])
	{
		line->cursorpos = line->size;
	}
        if (ui->key_pressed[UIKEY_BACKSPACE])
        {
                if (line->cursorpos > 0)
                {
                        memmove(line->buf + line->cursorpos - 1,
                                line->buf + line->cursorpos,
                                line->size + 1 - line->cursorpos);
                        line->size -= 1;
                        line->cursorpos -= 1;
                }
        }
        if (ui->key_pressed[UIKEY_DELETE])
        {
                if (line->cursorpos < line->size)
                {
                        memmove(line->buf + line->cursorpos,
                                line->buf + line->cursorpos + 1,
                                line->size + 1 - line->cursorpos);
                        line->size -= 1;
                }
        }
        if (ui->have_unicode_input)
        {
            uint32_t code = ui->unicode_input;
            if (0 <= code && code < 256)
            {
                if (line->size + 1 < sizeof line->buf)
                {
                        memmove(line->buf + line->cursorpos + 1,
                                line->buf + line->cursorpos,
                                line->size + 1 - line->cursorpos);
                        line->buf[line->cursorpos] = (char) code;
                        line->cursorpos++;
                        line->size++;
                }
            }
        }
	if (ui->paste_input_size > 0)
	{
		int n = sizeof line->buf - (line->size + 1);
		if (n > ui->paste_input_size)
			n = ui->paste_input_size;
		memmove(line->buf + line->cursorpos + n, line->buf + line->cursorpos, line->size + 1 - line->cursorpos);
		memcpy(line->buf + line->cursorpos, ui->paste_input, n);
		line->size += n;
		line->cursorpos += n;
	}

	Ui_String text = Ui_String(line->buf, line->size);

	//XXX this work is done in the renderer as wel...
	ui_layout_text_line(ui, text, rect.x, rect.y, rect.w, &line->text_layout_cache, line->positions_storage);

	ui_add_quad_and_add_region(ui, rect, color_map[UICOLOR_HOVER], text, &line->region);

	Ui_Pos cursorpos = line->positions_storage[line->cursorpos];  //XXX out-of-bounds?
	ui_add_quad(ui, Ui_Rect(cursorpos.x /*XXX*/+ui->pad_size, cursorpos.y, 5, ui->font_face.current_nominal_height), color_map[UICOLOR_BORDER], ui_string(""));
}




void ui_do_floatedit(Ui *ui, Ui_Lineedit *edit, Ui_Rect rect, float *inout)
{
	UNUSED(inout);
        //snprintf(edit->buf, sizeof edit->buf, "%.2f", *inout);
        ui_do_lineedit(ui, edit, rect);
}




DEFINE_STRUCT(Ui_Slider)
{
        Ui_Region region;
        Ui_Region handle_region;
        const char *caption;
};

void ui_do_slider(Ui *ui, Ui_Slider *slider, Ui_Rect rect, float minval, float maxval, float *inout)
{
        float ratio = (*inout - minval) / (maxval - minval);

        int32_t x = rect.x;
        int32_t y = rect.y;
        int32_t w = rect.w;
        int32_t h = rect.h;

        int32_t sx = x + (int32_t)(ratio * (float)w);
        int32_t sy = y;
        int32_t sw = 10;
        int32_t sh = h;

        int is_hovered = (ui->hovered_region == &slider->region ||
                          ui->hovered_region == &slider->handle_region);

        if (ui->is_interacting && is_hovered)
        {
                sx = ui->mouse_x;
                if (sx < x) sx = x;
                if (sx > x + w) sx = x + w;
                ratio = (float)(sx - x) / w;
                *inout = minval + ratio * (maxval - minval);
        }
        else if (is_hovered)
        {
                if (ui->mousewheel_scrolled_up)
                {
                        ratio += 1.0f / 16;
                        if (ratio > 1.0f)
                                ratio = 1.0f;
                        sx = x + (int32_t)(ratio * (float)w);
                        *inout = minval + ratio * (maxval - minval);
                }
                if (ui->mousewheel_scrolled_down)
                {
                        ratio -= 1.0f / 16;
                        if (ratio < 0.0f)
                                ratio = 0.0f;
                        sx = x + (int32_t)(ratio * (float)w);
                        *inout = minval + ratio * (maxval - minval);
                }
        }

        Ui_Rect rail_rect = { x, y + h / 2 - 3, w, 6 };

        Ui_Rect handle_rect = { sx - sw / 2, sy, sw, sh };

        uint32_t color = is_hovered ? ui->is_interacting ? color_map[UICOLOR_INTERACTING] : color_map[UICOLOR_HOVER] : color_map[UICOLOR_BACKGROUND];

        ui_add_region(ui, &slider->region, rect);
        ui_add_quad(ui, rail_rect, color, ui_string(""));
        ui_add_quad_and_add_region(ui, handle_rect, color, ui_string(""), &slider->handle_region);
}

DEFINE_STRUCT(Ui_Button)
{
        Ui_Rect area;
        Ui_Region region;
        int32_t optimal_width;
        int32_t optimal_height;
};

// Returns whether button was clicked.
int ui_do_button(Ui *ui, Ui_Button *button, Ui_String text)
{
        Ui_Region *region = &button->region;

        int was_clicked = ui->hovered_region == region && ui->was_interacting && ui->mousebutton_released;

        int32_t color = color_map[UICOLOR_BACKGROUND];
        if (ui->hovered_region == region)
                color = (ui->is_interacting) ? color_map[UICOLOR_INTERACTING] : color_map[UICOLOR_HOVER];

        Ui_Rect shadow_rect = Ui_Rect(button->area.x - 2, button->area.y - 2, button->area.w + 4, button->area.h + 4);  //XXX
        
        ui_add_quad_and_add_region(ui, shadow_rect, RGB(16,16,16), text, region);
        ui_add_quad_and_add_region(ui, button->area, color, text, region);

        return was_clicked;
}




DEFINE_STRUCT(Ui_Selectbox)
{
	Ui_Button button; //XXX
	int open;
};

void ui_do_selectbox(Ui *ui, Ui_Selectbox *sb, const char **options, int count)
{

	sb->button.area = ui_cut_layout_rect(ui, UISIDE_TOP, 30); //XXX
	if (ui_do_button(ui, &sb->button, ui_string("SELECT")))
		sb->open ^= 1;


	if (sb->open)
	{
		ui_dup_layout_rect(ui);
		ui_pad_layout_rect(ui);
		// TODO: frame allocation
		static Ui_Button static_buttons[128];

		for (int i = 0; i < count; i++)
		{
			Ui_Button *btn = static_buttons + i;
			btn->area = ui_cut_layout_rect(ui, UISIDE_TOP, 25);
			ui_do_button(ui, btn, ui_string(options[i]));
		}
		ui_pop_layout_rect(ui);
	}
}









DEFINE_STRUCT(Ui_Menu_Item)
{
        Ui_Region region;
        char buffer[128];
        int size;
        uint32_t color;
        Ui_Button button;
};

DEFINE_STRUCT(Ui_Menu)
{
        Ui_Toplevel_Window toplevel_window;

        char title[64];

        Ui_Rect rect;

        Ui_Menu_Item items[64];
        Ui_Rect items_old_rects[256];
        Ui_Rect items_rects[256];
        int items_layout_vertical;
        float items_rects_interpolation_value;
        int num_items;

        Ui_Lineedit test_lineedit;

        Ui_Slider slider;
        float slider_test_value;

        Ui_Button new_item_button;
};

Ui_Menu_Item *ui_menu_add_item(Ui_Menu *menu, const char *name)
{
        if (menu->num_items == ARRAY_COUNT(menu->items))
                return NULL;
        Ui_Menu_Item *item = menu->items + menu->num_items++;
        snprintf(item->buffer, sizeof item->buffer, "%s", name);
        item->color = RGB(64, 64, 64);
        return item;
}

void ui_update_menu(Ui *ui, Ui_Menu *menu)
{
        snprintf(menu->title, sizeof menu->title, "%s: %.2f", "TEST", menu->slider_test_value);

        ui_begin_toplevel_window(ui, &menu->toplevel_window, menu->rect, menu->title);
        {
                // Layout animation.
                if (menu->items_rects_interpolation_value > 0.0f)
                {
                        menu->items_rects_interpolation_value -= 1.0f / 32.0f;
                }

                // Change layout type on user request.
                if (ui->key_down[UIKEY_ALT] && (ui->key_pressed[UIKEY_CURSORLEFT] || ui->key_pressed[UIKEY_CURSORRIGHT]))
                {
                        menu->items_layout_vertical = ui->key_pressed[UIKEY_CURSORRIGHT];
                        // reset animation. XXX see below. Where to do this?
                        menu->items_rects_interpolation_value = 1.0f;
                        for (int i = 0; i < menu->num_items; i++)
                                menu->items_old_rects[i] = menu->items_rects[i];
                }

                ui_push_cut_layout_rect(ui, UISIDE_TOP, 60);
                ui_pad_layout_rect(ui);
                menu->new_item_button.area = ui_get_layout_rect(ui);
                if (ui_do_button(ui, &menu->new_item_button, ui_string("New item")))
                        ui_menu_add_item(menu, "Foo");
                ui_pop_layout_rect(ui);

                // Do menu items.
                {
                        Ui_Layout_Info layout_infos[128];
                        assert(menu->num_items <= ARRAY_COUNT(layout_infos));
                        for (int i = 0; i < menu->num_items; i++)
                        {
                                Ui_Menu_Item *item = menu->items + i;
                                layout_infos[i].out_rect = menu->items_rects + i;
                                layout_infos[i].optimal_width = 2 * ui->pad_size + ui_measure_text(ui, ui_string(item->buffer));  //XXX
                                layout_infos[i].optimal_height = 40 + 2 * ui->pad_size;
                        }
                        
                        Ui_Layout layout = { 0 };
                        layout.layout_infos = layout_infos;
                        layout.num_layout_infos = menu->num_items;

                        Ui_Rect saved_rects[128]; //XXX XXX only for a quick test.
                        for (int i = 0; i < menu->num_items; i++)
                                saved_rects[i] = menu->items_rects[i];

                        // Do layout
                        {
                                Ui_Rect layout_rect = ui_get_layout_rect(ui);
                                layout_rect.x = 0;  // normalize
                                layout_rect.y = 0;  // normalize

                                if (menu->items_layout_vertical)
                                {
                                        ui_do_layout_vertical(ui, &layout, layout_rect);
                                        ui_push_cut_layout_rect(ui, UISIDE_TOP, layout.optimal_height);
                                }
                                else
                                {
                                        ui_do_layout_horizontal(ui, &layout, layout_rect);
                                        ui_push_cut_layout_rect(ui, UISIDE_TOP, layout.optimal_height);
                                }
                        }

                        // XXX: if we detect a change, reset the animation.
                        for (int i = 0; i < menu->num_items; i++)
                        {
                                Ui_Rect ra = menu->items_rects[i];
                                Ui_Rect rb = saved_rects[i];
                                if (ra.x != rb.x || ra.y != rb.y || ra.w != rb.w || ra.h != rb.h)
                                {
                                        // reset animation. XXX see above. Where to do this?
                                        menu->items_rects_interpolation_value = 1.0f;
                                        for (int j = 0; j < menu->num_items; j++)
                                                menu->items_old_rects[j] = saved_rects[j];
                                        break;
                                }
                        }

                        // Animation
                        float s = menu->items_rects_interpolation_value;
                        //float t = 3 * s * s - 2 * s * s * s;  // smoothstep
                        float t = s * s * s * (s * (s * 6 - 15) + 10);  // smootherstep
                        for (int i = 0; i < menu->num_items; i++)
                        {
                                Ui_Menu_Item *item = menu->items + i;
                                Ui_Rect ra = menu->items_old_rects[i];
                                Ui_Rect rb = menu->items_rects[i];
                                item->button.area.x = (int32_t) (t * ra.x + (1.0f - t) * rb.x);
                                item->button.area.y = (int32_t) (t * ra.y + (1.0f - t) * rb.y);
                                item->button.area.w = (int32_t) (t * ra.w + (1.0f - t) * rb.w);
                                item->button.area.h = (int32_t) (t * ra.h + (1.0f - t) * rb.h);

                                Ui_Rect child_rect = ui_get_layout_rect(ui);
                                item->button.area.x += child_rect.x;
                                item->button.area.y += child_rect.y;

                                ui_do_button(ui, &item->button, ui_string(item->buffer));
                        }

                        ui_pop_layout_rect(ui);
                }

                // Test-value slider.
                ui_do_slider(ui, &menu->slider, ui_cut_layout_rect(ui, UISIDE_TOP, 30), 0.0f, 1.0f, &menu->slider_test_value);

                // Add float edit.
                if (1)
                {
                        float test_float = 3.0f;
                        ui_do_floatedit(ui, &menu->test_lineedit, ui_cut_layout_rect(ui, UISIDE_TOP, ui->font_face.current_nominal_height), &test_float);
                }
        }
        ui_end_toplevel_window(ui, &menu->toplevel_window);

        if (menu->items_rects_interpolation_value > 0.0f)
                ui->is_animation_active = 1;
}



DEFINE_STRUCT(MyApp) {
        // some more concrete state.
        Ui_Menu menus[2];
        int num_menus;
};

static MyApp app_;
static MyApp *app = &app_;


void update_ui(Ui *ui)
{
        if (!ui->initialized)
        {
                ui->initialized = 1;
                ui->pad_size = 10;
                ui->root_region = (Ui_Region) { .rect = Ui_Rect(.w = 1000, .h = 200) };
                ui->region_stack = &ui->root_region;

                for (int i = 0; i < ARRAY_COUNT(ui->captions); i++)
                        ui->captions[i][0] = 'A';

                {
                        Ui_Menu *menu = app->menus + app->num_menus++;
                        menu->rect = Ui_Rect(100, 200, 400, 400);
                        for (int i = 0; i < 4; i++)
                                ui_menu_add_item(menu, "TEST");
                }

                {
                        Ui_Menu *menu = app->menus + app->num_menus++;
                        menu->rect = Ui_Rect(600, 200, 400, 400);
                        for (int i = 0; i < 3; i++)
                                ui_menu_add_item(menu, "TEST");
                }

                load_font(&ui->font_face, "fonts/NotoSans/NotoSans-Regular.ttf");

		set_font_size(&ui->font_face, 20);
        }

        for (int i = 0; i < NUM_UIKEYS; i++)
                ui->key_pressed[i] = ui->key_down[i] && ui->key_down[i] != ui->key_was_down[i];  // XXX NOTE it's a repeat count as well.

        ui->mousebutton_pressed = (ui->mousebutton_down && !ui->mousebutton_was_down);
        ui->mousebutton_released = (!ui->mousebutton_down && ui->mousebutton_was_down);
        ui->mouse_dx = ui->mouse_x - ui->mouse_last_x;
        ui->mouse_dy = ui->mouse_y - ui->mouse_last_y;

        // Set hovered region.
        if (! ui->is_interacting)
                ui->hovered_region = ui_find_region_at(&ui->root_region, ui->mouse_x, ui->mouse_y);

        if (!ui->was_interacting && ui->hovered_region && ui->mousebutton_pressed)
        {
                ui->is_interacting = 1;
                ui->interacting_start_x = ui->mouse_x;
                ui->interacting_start_y = ui->mouse_y;
                ui->interacting_start_rect = ui->hovered_region->rect;
        }
        else if (ui->was_interacting && ui->mousebutton_released)
        {
                ui->is_interacting = 0;
        }

        ui->interacting_since_start_dx = ui->mouse_x - ui->interacting_start_x;
        ui->interacting_since_start_dy = ui->mouse_y - ui->interacting_start_y;

        if (ui->hovered_region != NULL)
                ui->want_cursor_kind = ui->hovered_region->cursor_kind;
        else
                ui->want_cursor_kind = UICURSOR_NORMAL;

        if (ui->key_pressed[UIKEY_TAB])
        {
                Ui_Region *region = ui->focused_region;
                if (!region)
                        region = &ui->root_region;
                else if (region->first_child)
                        region = region->first_child;
                else if (region->next_sibling)
                        region = region->next_sibling;
                else
                        region = region->parent;
                ui->focused_region = region;
        }

        if (ui->key_pressed[UIKEY_F11])
        {
                ui->want_fullscreen ^= 1;
        }

        if (ui->platform_requested_close)
        {
                ui->want_close = 1;
        }
        
        ui->is_animation_active = 0; // XXX can be set by usage code

        static int frameno;
        static char statusbar_text[128];
        snprintf(statusbar_text, sizeof statusbar_text,
                "Frame: %d"
                ", X: %d, Y: %d, Width: %d, Height: %d"
                ", hovered: %d, interacting: %d, Cursor: %d",
                frameno++,
                (int)ui->win_x, (int)ui->win_y, (int)ui->win_w, (int)ui->win_h,
                ui->hovered_region != NULL, ui->is_interacting, ui->want_cursor_kind);

        //
        // Re-draw UI
        //

        Ui_Rect window_rect = Ui_Rect(0, 0, ui->win_w, ui->win_h);

        assert(ui->layout_rect_stack_size <= 1);
        ui->layout_rect_stack_size = 0;
        ui->layout_rect_stack[ui->layout_rect_stack_size++] = window_rect;
        ui->clip_rect = window_rect;  // is this still needed or can we just use rect_stack?
        ui->root_region = (Ui_Region) { 0 }; // need to clear regions before re-creating
        ui->render_batch_stack = NULL;
        ui->first_render_batch = NULL;
        ui->last_render_batch = NULL;


        ui_enable_render_batch(ui, &ui->render_batch);
        ui_begin_render_batch(ui, &ui->render_batch);
        {
                int32_t text_height = ui->font_face.current_nominal_height;

                // clear background and draw statusbar.
                ui_add_quad(ui, window_rect, RGB(128, 128, 128), ui_string(""));
                ui_add_quad(ui, ui_cut_layout_rect(ui, UISIDE_TOP, text_height), color_map[UICOLOR_TITLEBAR], ui_string(statusbar_text));

                // draw help text
                ui_dup_layout_rect(ui);
                ui_pad_layout_rect(ui);
                {
                        ui_add_quad(ui, ui_cut_layout_rect(ui, UISIDE_TOP, text_height), RGB(255,255,255), ui_string("F11: toggle Fullscreen"));
                        ui_add_quad(ui, ui_cut_layout_rect(ui, UISIDE_TOP, text_height), RGB(255,255,255), ui_string("Alt + Left/Right arrow: change layout"));
                        ui_add_quad(ui, ui_cut_layout_rect(ui, UISIDE_TOP, text_height), RGB(255,255,255), ui_string("Alt + Left drag window: drag window"));
                        ui_add_quad(ui, ui_cut_layout_rect(ui, UISIDE_TOP, text_height), RGB(255,255,255), ui_string("Left drag window titlebar: drag window"));
                        ui_add_quad(ui, ui_cut_layout_rect(ui, UISIDE_TOP, text_height), RGB(255,255,255), ui_string("Left drag window border: resize window"));                        

			// Renderer mode info.
                        if (ui->key_pressed[UIKEY_F1]) win32_renderer_mode = (win32_renderer_mode + 1) % NUM_WIN32_RENDERER_MODES;
                        static char message[128]; //XXX should be moved to frame or batch memory
                        snprintf(message, sizeof message, "F1: Rotate renderer mode [%s]", win32_renderer_mode_string[win32_renderer_mode]);
                        ui_add_quad(ui, ui_cut_layout_rect(ui, UISIDE_TOP, text_height), RGB(255,255,255), ui_string(message));


			// Test: selectbox
			{
				static Ui_Selectbox selectbox;
				const char *options[] = { "A", "B", "C" };

				int count = ARRAY_COUNT(options);

				ui_do_selectbox(ui, &selectbox, options, count);
			}
                }
                ui_pop_layout_rect(ui);
        }
        ui_end_render_batch(ui);

        // draw color choosers
        {
                static Render_Batch render_batch;
                ui_enable_render_batch(ui, &render_batch);
                ui_begin_render_batch(ui, &render_batch);


                int32_t width = 210;
                int32_t title_h = 50;
                int32_t slider_h = 30;
                int32_t total_h = title_h + 3 * slider_h + 2 * ui->pad_size;

                static Ui_Slider color_sliders[NUM_UICOLORS][3];
                static char color_titles[NUM_UICOLORS][256];

                for (int color_index = 0;
                        color_index < NUM_UICOLORS;
                        color_index++)
                {
                        Ui_Slider *rgb_sliders = color_sliders[color_index];
                        rgb_sliders[0].caption = "R";
                        rgb_sliders[1].caption = "G";
                        rgb_sliders[2].caption = "B";
                }

                ui_push_cut_layout_rect(ui, UISIDE_BOTTOM, total_h);
                for (int color_index = 0;
                        color_index < NUM_UICOLORS;
                        color_index++)
                {
                        uint32_t *c = color_map + color_index;

                        float color_r = (float) GetRValue(*c);
                        float color_g = (float) GetGValue(*c);
                        float color_b = (float) GetBValue(*c);

                        snprintf(color_titles[color_index], sizeof color_titles[color_index],
                                "%s: %3d,%3d,%3d", ui_color_name(color_index), (int)color_r, (int)color_g, (int)color_b);

                        ui_push_cut_layout_rect(ui, UISIDE_LEFT, width);
                        ui_pad_layout_rect(ui);
                        ui_add_quad(ui, ui_cut_layout_rect(ui, UISIDE_TOP, title_h), *c, ui_string(color_titles[color_index]));
                        ui_do_slider(ui, &color_sliders[color_index][0], ui_cut_layout_rect(ui, UISIDE_TOP, slider_h), 0.0, 255.0, &color_r);
                        ui_do_slider(ui, &color_sliders[color_index][1], ui_cut_layout_rect(ui, UISIDE_TOP, slider_h), 0.0, 255.0, &color_g);
                        ui_do_slider(ui, &color_sliders[color_index][2], ui_cut_layout_rect(ui, UISIDE_TOP, slider_h), 0.0, 255.0, &color_b);
                        ui_pop_layout_rect(ui);

                        *c = RGB((int) color_r, (int) color_g, (int) color_b);
                }
                ui_pop_layout_rect(ui);

                ui_end_render_batch(ui);
        }


	// draw font size chooser.
	{
		static Render_Batch render_batch;
		ui_enable_render_batch(ui, &render_batch);
		ui_begin_render_batch(ui, &render_batch);

		static Ui_Slider slider;
		static char buf[128];
		float float_font_size = ui->font_face.current_size;
		snprintf(buf, sizeof buf, "Font size (changing leads eventually to out-of-memory situation): %f", float_font_size);
		uint32_t color = color_map[UICOLOR_BACKGROUND];
		ui_do_slider(ui, &slider, ui_cut_layout_rect(ui, UISIDE_BOTTOM, ui->font_face.current_nominal_height), 10.0f, 50.0f, &float_font_size);
		ui_add_quad(ui, ui_cut_layout_rect(ui, UISIDE_BOTTOM, ui->font_face.current_nominal_height), color, ui_string(buf));

		set_font_size(&ui->font_face, (uint8_t) float_font_size);

		ui_end_render_batch(ui);
	}

        for (int i = 0; i < app->num_menus; i++)
        {
                Ui_Menu *menu = app->menus + i;
                Ui_Toplevel_Window *tlw = &menu->toplevel_window;

                if (!tlw->is_closed)
                        ui_update_menu(ui, menu);
                if (!tlw->is_closed)
                        ui_enable_render_batch(ui, &menu->toplevel_window.render_batch); //XXX
        }

        // Set variables for next time.
        memcpy(ui->key_was_down, ui->key_down, sizeof ui->key_down);

        ui->was_interacting = ui->is_interacting;
        ui->mousebutton_was_down = ui->mousebutton_down;
        ui->mouse_last_x = ui->mouse_x;
        ui->mouse_last_y = ui->mouse_y;

        ui->mousewheel_scrolled_up = 0;
        ui->mousewheel_scrolled_down = 0;

        ui->have_unicode_input = 0;
	ui->paste_input_size = 0;
}



//////////////////////////////////////////////////////////////////
// OpenGL Function pointers
//////////////////////////////////////////////////////////////////

#define OPENGL_FUNCTIONS \
    OPENGL_FUNCTION(PFNGLCREATEBUFFERSPROC, glCreateBuffers) \

DEFINE_STRUCT(OpenGL_Function_Pointers)
{
#define OPENGL_FUNCTION(type, name) type name;
        OPENGL_FUNCTIONS
#undef OPENGL_FUNCTION
};

DEFINE_STRUCT(OpenGL_Function_Pointer_Info)
{
        const char *name;
        int offset;
};

static const OpenGL_Function_Pointer_Info opengl_function_pointer_infos[] = {
    #define OPENGL_FUNCTION(type, name) { #name, offsetof(OpenGL_Function_Pointers, name) },
    OPENGL_FUNCTIONS
    #undef OPENGL_FUNCTION
};

//////////////////////////////////////////////////////////////////
// Win32 backend
//////////////////////////////////////////////////////////////////


DEFINE_STRUCT(Win32_DIB)
{
        HBITMAP hbitmap;
        void *data;
        int32_t w;
        int32_t h;
        // all are 32 bits (BGRA) for now.
};

void win32_recreate_dib(Win32_DIB *wd, int32_t w, int32_t h)
{
        LONG biWidth = (LONG)w; // TODO: check
        LONG biHeight = (LONG)h; // TODO: check
        DWORD biSizeImage = (DWORD) w * h * 4;  // TODO: check
        BITMAPINFO bmi = { 0 };
        bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
        bmi.bmiHeader.biWidth = biWidth;
        bmi.bmiHeader.biHeight = biHeight;
        bmi.bmiHeader.biPlanes = 1;
        bmi.bmiHeader.biBitCount = 32;         // four 8-bit components 
        bmi.bmiHeader.biCompression = BI_RGB;
        bmi.bmiHeader.biSizeImage = biSizeImage;
        void *data_ptr = NULL;
        if (wd->hbitmap)
        {
                DeleteObject(wd->hbitmap);
                wd->hbitmap = NULL;
        }
        wd->hbitmap = CreateDIBSection(NULL /* hdc needed? */, &bmi, DIB_RGB_COLORS, &data_ptr, NULL, 0x0);
        wd->data = data_ptr;
        wd->w = w;
        wd->h = h;

        if (!wd->hbitmap || !wd->data)
                if (wd->w || wd->h)
                        fatal_f("CreateDIBSection() failed");
}

DEFINE_STRUCT(Win32_Window)
{
        HWND hwnd;
        HDC hwnd_hdc;

        HDC backbuffer_hdc;

        Win32_DIB backbuffer_DIB;

        Win32_DIB fontatlas_DIB;
        int fontatlas_is_synced;
        uint32_t fontatlas_generation;
        uint32_t fontatlas_color;


        HGLRC hglrc;

        int is_fullscreen;
        WINDOWPLACEMENT previous_placement;

        HCURSOR cursors[NUM_UICURSORS];
        int cursor_kind;

        Ui *ui; //XXX removeme

        int opengl_version_major;
        int opengl_version_minor;
        const char *wgl_extensions_string;
        OpenGL_Function_Pointers opengl_funcptrs;
};


void win32_refresh_win(Win32_Window *win)
{
        Ui *ui = win->ui;
        
        update_ui(win->ui);
        InvalidateRect(win->hwnd, NULL, FALSE);

        if (ui->want_fullscreen && !win->is_fullscreen)
        {
                win->is_fullscreen = 1;
                if (!GetWindowPlacement(win->hwnd, &win->previous_placement))
                {
                        msg_f("Failed to query current window placement. Not entering fullscreen");
                }
                else
                {
                        POINT Point = { 0 };
                        HMONITOR Monitor = MonitorFromPoint(Point, MONITOR_DEFAULTTONEAREST);
                        MONITORINFO MonitorInfo = { sizeof(MonitorInfo) };
                        if (GetMonitorInfo(Monitor, &MonitorInfo))
                        {
                                DWORD Style = WS_POPUP | WS_VISIBLE;
                                SetWindowLongPtr(win->hwnd, GWL_STYLE, Style);
                                SetWindowPos(win->hwnd, 0, MonitorInfo.rcMonitor.left, MonitorInfo.rcMonitor.top,
                                        MonitorInfo.rcMonitor.right - MonitorInfo.rcMonitor.left, MonitorInfo.rcMonitor.bottom - MonitorInfo.rcMonitor.top,
                                        SWP_FRAMECHANGED | SWP_SHOWWINDOW);
                        }
                }
        }
        else if (!ui->want_fullscreen && win->is_fullscreen)
        {
                win->is_fullscreen = 0;
                DWORD Style = WS_OVERLAPPEDWINDOW | WS_VISIBLE | WS_CLIPCHILDREN;
                SetWindowLongPtr(win->hwnd, GWL_STYLE, Style);
                if (!SetWindowPlacement(win->hwnd, &win->previous_placement))
                        msg_f("Failed to restore previous window placement");
        }
}

void win32_update_window_geometry(Win32_Window *win)
{
        RECT rect;
        GetClientRect(win->hwnd, &rect);

        Ui *ui = win->ui;
        ui->win_x = rect.left;
        ui->win_y = rect.top;
        ui->win_w = rect.right - rect.left;
        ui->win_h = rect.bottom - rect.top;

        if (win->backbuffer_hdc)
                DeleteDC(win->backbuffer_hdc);
        win->backbuffer_hdc = CreateCompatibleDC(win->hwnd_hdc);

        win32_recreate_dib(&win->backbuffer_DIB, ui->win_w, ui->win_h);

        win32_refresh_win(win);
}


void win32_render_batch(Win32_Window *win, Render_Batch *batch)
{
        HDC fontatlas_hdc = CreateCompatibleDC(win->backbuffer_hdc);
        SelectObject(fontatlas_hdc, win->fontatlas_DIB.hbitmap);

        HBRUSH brush = GetStockObject(DC_BRUSH);
        HBRUSH original_brush = SelectObject(win->backbuffer_hdc, brush);

        for (int quad_index = 0;
                quad_index < batch->num_quads;
                quad_index++)
        {
                Render_Quad *quad = batch->quads + quad_index;

                RECT rect;
                rect.left = quad->x;
                rect.top = quad->y;
                rect.right = quad->x + quad->w;
                rect.bottom = quad->y + quad->h;

                rect.left   = maximum_int32(rect.left, quad->clip_x);
                rect.top    = maximum_int32(rect.top, quad->clip_y);
                rect.right  = minimum_int32(rect.right, quad->clip_x + quad->clip_w);
                rect.bottom = minimum_int32(rect.bottom, quad->clip_y + quad->clip_h);

                // TODO: make sure that all quads get automatically clipped by window size?
                rect.left   = maximum_int32(rect.left, 0);
                rect.top    = maximum_int32(rect.top, 0);
                rect.right  = minimum_int32(rect.right, win->backbuffer_DIB.w);
                rect.bottom = minimum_int32(rect.bottom, win->backbuffer_DIB.h);

                rect.right  = maximum_int32(rect.left, rect.right);
                rect.bottom = maximum_int32(rect.top, rect.bottom);

                if (win32_renderer_mode == WIN32_RENDERER_MODE_BLIT32
                        || win32_renderer_mode == WIN32_RENDERER_MODE_BLIT64)
                {
                        uint32_t color = 0
                                | GetBValue(quad->color) << 0
                                | GetGValue(quad->color) << 8
                                | GetRValue(quad->color) << 16
                                | (quad->color & 0xFF) << 24
                                ;
                        for (int j = rect.top; j < rect.bottom; j++)
                        {
                                if (win32_renderer_mode == WIN32_RENDERER_MODE_BLIT32)
                                {
                                        uint32_t pixel_index = (win->backbuffer_DIB.h - j - 1) * win->backbuffer_DIB.w + rect.left;
                                        uint32_t *buf = (uint32_t *)win->backbuffer_DIB.data + pixel_index;
                                        int stride = rect.right - rect.left;
                                        for (int i = 0; i < stride; i++)
                                                *buf++ = color;
                                }
                                else if (win32_renderer_mode == WIN32_RENDERER_MODE_BLIT64)
                                {
                                        uint32_t pixel_index = (win->backbuffer_DIB.h - j - 1) * win->backbuffer_DIB.w + rect.left;
                                        uint64_t *buf2 = (uint64_t *)win->backbuffer_DIB.data + (pixel_index + 1) / 2;
                                        uint64_t color2 = ((uint64_t)color << 32) | color;
                                        int stride = (rect.right - rect.left) / 2;
                                        for (int i = 0; i < stride; i++)
                                                *buf2++ = color2;
                                }
                        }
                }
                else
                {

                        IntersectClipRect(win->backbuffer_hdc, quad->clip_x, quad->clip_y, quad->clip_x + quad->clip_w, quad->clip_y + quad->clip_h);
                        SetDCBrushColor(win->backbuffer_hdc, quad->color);
                        if (win32_renderer_mode == WIN32_RENDERER_MODE_FILLRECT)
                        {
                                FillRect(win->backbuffer_hdc, &rect, brush);
                                FrameRect(win->backbuffer_hdc, &rect, (HBRUSH) COLOR_BACKGROUND + 1);
                        }
                        else
                        {
                                RoundRect(win->backbuffer_hdc, rect.left, rect.top, rect.right, rect.bottom, 10, 10);
                        }
                }

                // XXX test
                Ui *ui = win->ui;

                static Ui_Pos positions_storage[128]; //XXX
                Text_Layout_Cache text_layout_cache = { 0 };
                ui_layout_text_line(ui, quad->text, quad->x + ui->pad_size, quad->y + quad->h * 2 / 3, quad->w, &text_layout_cache, positions_storage);

                BLENDFUNCTION blendfunction = { 0 };
                blendfunction.BlendOp = AC_SRC_OVER;
                blendfunction.BlendFlags = 0;
                blendfunction.SourceConstantAlpha = 255;  // no constant alpha: we use per-pixel alpha.
                blendfunction.AlphaFormat = AC_SRC_ALPHA;

                for (int cp = 0; cp < text_layout_cache.size; cp++)
                {
                        Ui_Pos pos = text_layout_cache.positions[cp];
                        uint32_t codepoint = text_layout_cache.characters[cp];
                        Cached_Glyph *glyph = get_glyph(&ui->font_atlas, &ui->font_face, codepoint);
                        int32_t x = pos.x + glyph->dx;
                        int32_t y = pos.y + glyph->dy;
                        int32_t w = glyph->w;
                        int32_t h = glyph->h;
                        int32_t gx = glyph->x;
                        int32_t gy = glyph->y;
                        if (x < rect.left)
                        {
                                w -= rect.left - x;
                                gx += rect.left - x;
                                x = rect.left;
                        }
                        if (y < rect.top)
                        {
                                h -= rect.top - y;
                                gy += rect.top - y;
                                y = rect.top;
                        }
                        if (x + w > rect.right)
                        {
                                w = rect.right - x;
                        }
                        if (y + h > rect.bottom)
                        {
                                h = rect.bottom - y;
                        }
                        AlphaBlend(win->backbuffer_hdc, x, y, w, h, fontatlas_hdc, gx, gy, w, h, blendfunction);
                        GdiFlush();
                }

                SelectClipRgn(win->backbuffer_hdc, NULL);
        }
        SelectObject(win->backbuffer_hdc, original_brush);

        DeleteDC(fontatlas_hdc);
}


void win32_paint_window(Win32_Window *win, HDC hdc /* Should this be a "class member"? */)
{
        // Update Font Atlas. This is costly, so we need some caching.
        if (win->fontatlas_color != color_map[UICOLOR_FONT])
                win->fontatlas_is_synced = 0;

        if (! win->fontatlas_is_synced || win->fontatlas_generation != win->ui->font_atlas.generation) // need two iteractions because the drawing code below might insert new glyphs into the texture atlas.
        {
                win->fontatlas_is_synced = 1;
                win->fontatlas_generation = win->ui->font_atlas.generation;
                win->fontatlas_color = color_map[UICOLOR_FONT];

                win32_recreate_dib(&win->fontatlas_DIB, 1024, 1024); // Create fontatlas storage

		
		// Produce some char on the atlas
		{
			Font_Atlas *atlas = &win->ui->font_atlas;
			Font_Face *font = &win->ui->font_face;
			uint8_t old_size = font->current_size;
			set_font_size(font, 100);
			for (int character = 'A'; character <= 'Z'; character++)
				get_glyph(atlas, font, character);
			set_font_size(font, old_size);
		}

                Texture_8bit *tex8 = &win->ui->font_atlas.texture;
                static uint8_t tex_data[1024][1024][4];
                for (int i = 0; i < 1024; i++)
                {
                        for (int j = 0; j < 1024; j++)
                        {
                                int r = GetRValue(win->fontatlas_color);
                                int g = GetGValue(win->fontatlas_color);
                                int b = GetBValue(win->fontatlas_color);
                                // premultiplied alpha
                                tex_data[i][j][0] = (uint8_t) (b * tex8->buffer[1023 - i][j] / 255);
                                tex_data[i][j][1] = (uint8_t) (g * tex8->buffer[1023 - i][j] / 255);
                                tex_data[i][j][2] = (uint8_t) (r * tex8->buffer[1023 - i][j] / 255);
                                tex_data[i][j][3] = tex8->buffer[1023 - i][j];
                        }
                }

                memcpy(win->fontatlas_DIB.data, tex_data, sizeof tex_data);
        }

        Ui *ui = win->ui;

        SelectObject(win->backbuffer_hdc, win->backbuffer_DIB.hbitmap);

        //RECT window_rect = { .left = 0, .top = 0, .right = ui->win_w, .bottom = ui->win_h };
        //FillRect(win->backbuffer_hdc, &window_rect, GetStockObject(DC_BRUSH));
        //GdiFlush();

        for (Render_Batch *batch = ui->first_render_batch;
                batch; batch = batch->next_in_list)
        {
                win32_render_batch(win, batch);
        }


        // Font Atlas paint test
        if(0){
                BLENDFUNCTION blendfunction = { 0 };
                blendfunction.BlendOp = AC_SRC_OVER;
                blendfunction.BlendFlags = 0;
                blendfunction.SourceConstantAlpha = 255;  // no constant alpha: we use per-pixel alpha.
                blendfunction.AlphaFormat = AC_SRC_ALPHA;

                HDC fontatlas_hdc = CreateCompatibleDC(win->backbuffer_hdc);
                HBITMAP original_hbitmap = SelectObject(fontatlas_hdc, win->fontatlas_DIB.hbitmap);
                AlphaBlend(win->backbuffer_hdc, 0, 0, 1024, 1024, fontatlas_hdc, 0, 0, 1024, 1024, blendfunction);
                SelectObject(fontatlas_hdc, original_hbitmap);
                DeleteDC(fontatlas_hdc);
        }

        BitBlt(hdc, 0, 0, ui->win_w, ui->win_h, win->backbuffer_hdc, 0, 0, SRCCOPY);
}

LRESULT CALLBACK win32_window_proc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
        if (uMsg == WM_CREATE)
        {
                // This is special in that GetWindowLongPtr() returns NULL
                // because we haven't had a chance yet to call SetWindowLongPtr().
                // We have to assume that the Win32_Window pointer was provided
                // as lParam argument to CreateWindowA(), so we can retrieve
                // it from the CREATESTRUCT.
                CREATESTRUCT *cs = (void *)lParam;
                Win32_Window *win = cs->lpCreateParams;
                win->hwnd = hwnd; // needed because it isn't set yet!
                // We don't use other members of cs, such as x, y, cx, cy, because
                // those aren't the outer window coordinates, not the usable (client) space.
                win32_update_window_geometry(win);
                return 0;
        }

        Win32_Window *win = (void *)GetWindowLongPtr(hwnd, 0);

        if (!win)
        {
                // There are other messages that can come in before we had any chance to SetWindowLongPtr().
                // Let's ignore those for now.
                return DefWindowProc(hwnd, uMsg, wParam, lParam);
        }

        Ui *ui = win->ui;

        if (uMsg == WM_CLOSE)
        {
                ui->platform_requested_close = 1;
                win32_refresh_win(win);
                return 0;
        }
        else if (uMsg == WM_DESTROY)
        {
                return 0;
        }
        else if (uMsg == WM_SIZE)
        {
                if (win)
                {
                        // We don't use lParam to determine new width/height, because
                        // the coordinates sent there aren't the outer window coordinates,
                        // not the usable (client) space.
                        win32_update_window_geometry(win);
                        win32_refresh_win(win);
                }
                return 0;
        }
        else if (uMsg == WM_MOVE)
        {
                if (win)
                {
                        // We don't use lParam to determine new width/height, because
                        // the coordinates sent there aren't the outer window coordinates,
                        // not the usable (client) space.
                        win32_update_window_geometry(win);
                        win32_refresh_win(win);  //??needed??
                }
                return 0;
        }
        else if (uMsg == WM_MOUSEMOVE)
        {
                ui->mouse_x = GET_X_LPARAM(lParam);
                ui->mouse_y = GET_Y_LPARAM(lParam);
                win32_refresh_win(win);
                return 0;
        }
        else if (uMsg == WM_SETCURSOR)
        {
                // Need to send it to DefWindowProc first, so it can do border resizing when needed.
                if (!DefWindowProc(hwnd, uMsg, wParam, lParam))
                {
                        //if (win->cursor_kind != ui->cursor_kind)
                        {
                                win->cursor_kind = ui->want_cursor_kind;
                                SetCursor(win->cursors[ui->want_cursor_kind]);
                        }
                }
                return TRUE;
        }
        else if (uMsg == WM_MOUSEWHEEL)
        {
                float d = (float)(int16_t)HIWORD(wParam) / WHEEL_DELTA;
                if (d > 0.0f)
                        ui->mousewheel_scrolled_up = 1;
                else if (d < 0.0f)
                        ui->mousewheel_scrolled_down = 1;
                win32_refresh_win(win);
                return 0;
        }
        else if (uMsg == WM_LBUTTONDOWN)
        {
                SetCapture(win->hwnd);
                ui->mousebutton_down = 1;
                win32_refresh_win(win);
                return 0;
        }
        else if (uMsg == WM_LBUTTONUP)
        {
                ReleaseCapture();
                ui->mousebutton_down = 0;
                win32_refresh_win(win);
                return 0;
        }
        else if (uMsg == WM_KEYDOWN || uMsg == WM_KEYUP
                || uMsg == WM_SYSKEYDOWN || uMsg == WM_SYSKEYUP)
        {
                if (uMsg == WM_SYSKEYDOWN || uMsg == WM_SYSKEYUP)
                        DefWindowProc(hwnd, uMsg, wParam, lParam);

                // I tried using GetKeyboardState() but I don't know how to use it to detect key repeats.
                //BYTE key_state[256];
                //if (!GetKeyboardState(key_state))
                  //      fatal_f("GetKeyboardState() failed");

                static const struct { WPARAM win32_key, ui_key; } key_map[] = {
                        { VK_RETURN, UIKEY_RETURN },
                        { VK_TAB, UIKEY_TAB},
                        { VK_ESCAPE, UIKEY_ESCAPE },
                        { VK_UP, UIKEY_CURSORUP },
                        { VK_DOWN, UIKEY_CURSORDOWN },
                        { VK_LEFT, UIKEY_CURSORLEFT },
                        { VK_RIGHT, UIKEY_CURSORRIGHT },
			{ VK_HOME, UIKEY_HOME },
			{ VK_END, UIKEY_END },
                        { VK_BACK, UIKEY_BACKSPACE },
                        { VK_DELETE, UIKEY_DELETE },
                        { VK_SHIFT, UIKEY_SHIFT },
                        { VK_CONTROL, UIKEY_CONTROL },
			{ VK_MENU, UIKEY_ALT },
			{ VK_F1, UIKEY_F1 },
			{ VK_F2, UIKEY_F2 },
			{ VK_F3, UIKEY_F3 },
			{ VK_F4, UIKEY_F4 },
			{ VK_F5, UIKEY_F5 },
			{ VK_F6, UIKEY_F6 },
			{ VK_F7, UIKEY_F7 },
			{ VK_F8, UIKEY_F8 },
			{ VK_F9, UIKEY_F9 },
			{ VK_F10, UIKEY_F10 },
                        { VK_F11, UIKEY_F11 },
			{ VK_F12, UIKEY_F12 },
                        { VK_SPACE, UIKEY_SPACE },
                };
                for (int i = 0; i < ARRAY_COUNT(key_map); i++)
                {
                        if (wParam == key_map[i].win32_key)
                        {
                                if (uMsg == WM_KEYUP || uMsg == WM_SYSKEYUP)
                                        ui->key_down[key_map[i].ui_key] = 0;
                                else {
                                        ui->key_down[key_map[i].ui_key] ++;  // increase repeat count so we can detect repeats (we do not have an event model)
                                        ui->key_down[key_map[i].ui_key] |= 0x80;
                                }
                        }
                }

                if (ui->key_down[UIKEY_CONTROL] && uMsg == WM_KEYDOWN && wParam == 'V')
                {
                        if (OpenClipboard(NULL))
                        {
                                HANDLE handle = GetClipboardData(CF_TEXT);
                                if (handle)
                                {
                                        int ret = snprintf(ui->paste_input, sizeof ui->paste_input, "%s", (char *)handle);
					if (ret >= sizeof ui->paste_input)
						ret = 0; //XXX
					ui->paste_input_size = ret;
                                }
                                CloseClipboard();
                        }
                }

                win32_refresh_win(win);
                return 0;
        }
        else if (uMsg == WM_CHAR /* || uMsg == WM_SYSCHAR */)
        {
                uint32_t codepoint = (uint32_t)wParam;
                if (codepoint == 0x08) // backspace, what to do? Probably depends on application state.
                {
                        return 0;
                }
                else if (codepoint == 0x16)  // Ctrl+V, what to do? Probably depends on application state.
                {
                }
                else
                {
                        ui->have_unicode_input = 1;
                        ui->unicode_input = codepoint;
                        win32_refresh_win(win);
                }
                return 1;
        }
        if (uMsg == WM_COMMAND)
        {
                switch (LOWORD(wParam))
                {
                case IDM_CUT:
                        ui->have_unicode_input = 1;
                        ui->unicode_input = 'F';
                        break;

                case IDM_COPY:
                        break;

                case IDM_PASTE:
                        break;

                case IDM_DELETE:
                        break;
                }
                return 0;
        }
        else if (uMsg == WM_ERASEBKGND)
        {
                return TRUE;
        }
        else if (uMsg == WM_PAINT)
        {
                PAINTSTRUCT ps;
                HDC hdc = BeginPaint(win->hwnd, &ps);
                {
                        win32_paint_window(win, hdc);
                }
                EndPaint(win->hwnd, &ps);

                //XXX bad code
                if (ui->is_animation_active)
                {
                        win32_refresh_win(win);
                }

                return 0;
        }
        else if (uMsg == WM_SHOWWINDOW)
        {
                return 0;
        }
        else if (uMsg == WM_ERASEBKGND)
        {
                /* An application should return nonzero in response to WM_ERASEBKGND
                if it processes the message and erases the background; this indicates
                that no further erasing is required. If the application returns zero,
                the window will remain marked for erasing. */
                return 1;
        }
        else if (uMsg == WM_GETMINMAXINFO)
        {
                return 0;
        }
        else if (uMsg == WM_WINDOWPOSCHANGING)
        {
                return 0;
        }
        else
        {
                return DefWindowProc(hwnd, uMsg, wParam, lParam);
        }
}



//////////////////////////////////////////////////////////////////
// WGL
//////////////////////////////////////////////////////////////////

/* This is a list of WGL extensions that we might or might not require at runtime.
Due to the way this code is implemented, support *by the compiler* is required in any case.
I.e. they must be known by the OpenGL headers on the system where this code is built. */
#define EXTENSIONS_WGL \
    WGL_EXTENSION(WGL_EXT_extensions_string) \
    WGL_EXTENSION(WGL_EXT_depth_float) \

DEFINE_STRUCT(WGL_Extension_Info)
{
        const char *name;
        int wgl_constant;
        int is_supported;
};

/* We cannot make this "const" currently, since the isSupported field is set
at runtime. We should separate this field out, but that would probably require
that we make our own extensions enum that starts at zero, for practical
reasons. */
static WGL_Extension_Info wgl_extension_infos[] = {
    #define WGL_EXTENSION(ext) { #ext, ext, 0 },
    EXTENSIONS_WGL
    #undef WGL_EXTENSION
};


#define FUNCPOINTERS_WGL \
    WGL_FUNCPTR(PFNWGLGETEXTENSIONSSTRINGARBPROC, wglGetExtensionsStringARB) \
    WGL_FUNCPTR(PFNWGLCREATECONTEXTATTRIBSARBPROC, wglCreateContextAttribsARB) \
    WGL_FUNCPTR(PFNWGLCHOOSEPIXELFORMATARBPROC, wglChoosePixelFormatARB) \

#define WGL_FUNCPTR(t, n) static t n;
FUNCPOINTERS_WGL
#undef WGL_FUNCPTR

static struct {
        void(**ptr)(void);
        const char *name;
} wgl_func_pointers_to_load[] = {
    #define WGL_FUNCPTR(t, n) { (void(**)(void)) & n, #n },
    FUNCPOINTERS_WGL
    #undef WGL_FUNCPTR
};


/* This function was adapted from https://gist.github.com/nickrolfe/1127313ed1dbf80254b614a721b3ee9c */
static void init_wgl_extensions(Win32_Window *win)
{
        // Before we can load extensions, we need a dummy OpenGL context, created using a dummy window.
        // We use a dummy window because you can only set the pixel format for a window once. For the
        // real window, we want to use wglChoosePixelFormatARB (so we can potentially specify options
        // that aren't available in PIXELFORMATDESCRIPTOR), but we can't load and use that before we
        // have a context.
        WNDCLASSA window_class = {
            .style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC,
            .lpfnWndProc = DefWindowProcA,
            .hInstance = GetModuleHandle(0),
            .lpszClassName = "Dummy_WGL_djuasiodwa",
        };

        if (!RegisterClassA(&window_class))
                fatal_f("Failed to register dummy window class.");

        HWND dummy_window = CreateWindowExA(
                0, window_class.lpszClassName, "Dummy OpenGL Window", 0,
                CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
                0, 0, window_class.hInstance, 0);

        if (!dummy_window)
                fatal_f("Failed to create dummy OpenGL window.");

        HDC dummy_dc = GetDC(dummy_window);

        PIXELFORMATDESCRIPTOR pfd = {
            .nSize = sizeof(pfd),
            .nVersion = 1,
            .iPixelType = PFD_TYPE_RGBA,
            .dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,
            .iLayerType = PFD_MAIN_PLANE,
            .cColorBits = 32,
            .cAlphaBits = 8,
            .cDepthBits = 24,
            .cStencilBits = 8,
        };

        int pixel_format = ChoosePixelFormat(dummy_dc, &pfd);

        if (!pixel_format)
                fatal_f("Failed to find a suitable pixel format.");

        if (!SetPixelFormat(dummy_dc, pixel_format, &pfd))
                fatal_f("Failed to set the pixel format.");

        HGLRC dummy_context = wglCreateContext(dummy_dc);

        if (!dummy_context)
                fatal_f("Failed to create a dummy OpenGL rendering context.");

        if (!wglMakeCurrent(dummy_dc, dummy_context))
                fatal_f("Failed to activate dummy OpenGL rendering context.");

        for (int i = 0; i < ARRAY_COUNT(wgl_func_pointers_to_load); i++)
        {
                const char *name = wgl_func_pointers_to_load[i].name;
                void(**dest)(void) = wgl_func_pointers_to_load[i].ptr;
                void(*ptr)(void) = (void(*)(void)) wglGetProcAddress(name);
                if (ptr == NULL)
                        fatal_f("failed to load function pointer for %s()", name);
                *dest = ptr;
        }

        win->wgl_extensions_string = wglGetExtensionsStringARB(dummy_dc);

        if (!win->wgl_extensions_string)
                fatal_f("wglGetExtensionsStringARB() failed");

        for (int i = 0; i < ARRAY_COUNT(wgl_extension_infos); i++)
        {
                const char *name = wgl_extension_infos[i].name;
                //int constant = wglExtensionsInfo[i].wglConstant;
                wgl_extension_infos[i].is_supported = !!strstr(win->wgl_extensions_string, name); //XXX
        }

        wglMakeCurrent(dummy_dc, NULL);
        wglDeleteContext(dummy_context);
        ReleaseDC(dummy_window, dummy_dc);
        DestroyWindow(dummy_window);
}

void win32_window_init(Win32_Window *win)
{
        init_wgl_extensions(win);

        HMODULE hInstance = GetModuleHandle(NULL);
        if (hInstance == NULL)
                fatal_f("Failed to GetModuleHandle(NULL)");
        int nWidth = 1600;
        int nHeight = 1000;

        WNDCLASSA wc = { 0 };
        wc.lpfnWndProc = win32_window_proc;
        wc.hInstance = hInstance;
        //wc.hbrBackground = (HBRUSH)(COLOR_BACKGROUND);
        wc.lpszClassName = "myclass";
        wc.hCursor = LoadCursor(NULL, IDC_ARROW);
        wc.style = CS_OWNDC;
        wc.cbWndExtra = sizeof(void *);  // extra memory to store context pointer

        if (!RegisterClassA(&wc))
                fatal_f("Failed to register window class");

        win->hwnd = CreateWindowA(wc.lpszClassName, "My Window", WS_OVERLAPPEDWINDOW | WS_VISIBLE, 150, 50, nWidth, nHeight, NULL, NULL, hInstance, win);
        if (win->hwnd == NULL)
                fatal_f("Failed to create window");

        SetWindowLongPtr(win->hwnd, 0, (LONG)win);

        win->hwnd_hdc = GetDC(win->hwnd);
        if (win->hwnd_hdc == NULL)
                fatal_f("Failed to GetDC() from HWND");

        // To set initial backbuffer etc.
        win32_update_window_geometry(win);

        // Set Cursors.
        win->cursors[UICURSOR_NORMAL] = LoadCursorA(NULL, IDC_ARROW);
        win->cursors[UICURSOR_HAND] = LoadCursorA(NULL, IDC_HAND);
        win->cursors[UICURSOR_RESIZE] = LoadCursorA(NULL, IDC_SIZEWE);

        /*
        FIND AND SET PIXEL FORMAT
        */

        int trysamplesettings[] = {
                16, 4, 1
        };
        int pixelFormat = 0; // initialize for the compiler
        int foundPixelFormat = 0;

        for (int i = 0; i < ARRAY_COUNT(trysamplesettings); i++) {
                int numSamples = trysamplesettings[i];
                const float pfAttribFList[] = { 0, 0 };
                const int piAttribIList[] = {
                        WGL_DRAW_TO_WINDOW_ARB, GL_TRUE,
                        WGL_SUPPORT_OPENGL_ARB, GL_TRUE,
                        WGL_COLOR_BITS_ARB, 32,
                        WGL_RED_BITS_ARB, 8,
                        WGL_GREEN_BITS_ARB, 8,
                        WGL_BLUE_BITS_ARB, 8,
                        WGL_ALPHA_BITS_ARB, 8,
                        WGL_DEPTH_BITS_ARB, 24,
                        WGL_STENCIL_BITS_ARB, 0,
                        WGL_DOUBLE_BUFFER_ARB, GL_TRUE,
                        WGL_PIXEL_TYPE_ARB, WGL_TYPE_RGBA_ARB,
                        WGL_SAMPLE_BUFFERS_ARB, GL_TRUE,
                        WGL_SAMPLES_ARB, numSamples,
                        0, 0
                };

                UINT nMaxFormats = 1;
                UINT nNumFormats;
                if (!wglChoosePixelFormatARB(win->hwnd_hdc, piAttribIList, pfAttribFList, nMaxFormats, &pixelFormat, &nNumFormats))
                        continue;
                /* Passing NULL as the PIXELFORMATDESCRIPTOR pointer. Does that work on all machines?
                The documentation is cryptic on the use of that value.
                In conjunction with wglChoosePixelFormatARB(), the method that you can find on the internet,
                which involves calling DescribePixelFormat() + passing non-NULL parameter here did not work
                on all machines for me. */
                if (!SetPixelFormat(win->hwnd_hdc, pixelFormat, NULL))
                        continue;

                foundPixelFormat = 1;
                break;
        }

        if (!foundPixelFormat)
                fatal_f("Failed to ChoosePixelFormat()");


        // Create OpenGL context

        win->opengl_version_major = 3;
        for (win->opengl_version_minor = 6;
                win->opengl_version_minor >= 0;
                win->opengl_version_minor--) {
                const int contextAttribs[] = {
                    WGL_CONTEXT_MAJOR_VERSION_ARB, win->opengl_version_major,
                    WGL_CONTEXT_MINOR_VERSION_ARB, win->opengl_version_minor,
                    WGL_CONTEXT_PROFILE_MASK_ARB,  WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
                    0,
                };
                win->hglrc = wglCreateContextAttribsARB(win->hwnd_hdc, 0, contextAttribs);
                if (win->hglrc)
                        break;
        }

        if (!win->hglrc)
                fatal_f("Failed to create a sufficient OpenGL context.");

        if (!wglMakeCurrent(win->hwnd_hdc, win->hglrc))
                fatal_f("Failed to wglMakeCurrent(globalDC, globalGLRC);");

        // Load OpenGL Function pointers
        for (int i = 0; i < ARRAY_COUNT(opengl_function_pointer_infos); i++) {
                const char *name = opengl_function_pointer_infos[i].name;
                int offset = opengl_function_pointer_infos[i].offset;

                void(*funcptr)(void) = (void(*)(void)) wglGetProcAddress(name);
                if (funcptr == NULL)
                        fatal_f("OpenGL extension %s not found\n", name);

                *(void(**)(void)) ((char *)&win->opengl_funcptrs + offset) = funcptr;
        }
}

#if 0
void set_window_title(Win32_Window *win, const char *name)
{
        if (!SetWindowTextA(win->hwnd, name))
                msg_f("Warning: failed to set window title (request was '%s')", name);
}


void swap_buffers(Win32_Window *win)
{
        if (!SwapBuffers(win->hwnd_hdc))
                fatalf("Failed to SwapBuffers()");
}
#endif




static const struct {
        void (*setup_func)(void);
        void (*teardown_func)(void);
} modules[] = {
        { setup_freetype, teardown_freetype },
};




int main()
{
        SetProcessDPIAware();  // Please, dear Windows, don't mess with my pixels.


        static Ui _ui_storage;
        Ui *ui = &_ui_storage;

        Win32_Window *win = &(Win32_Window) { .ui = ui };

        for (int i = 0; i < ARRAY_COUNT(modules); i++)
        {
                modules[i].setup_func();
        }

        win32_window_init(win);

        while (!ui->want_close)
        {
                MSG msg;
                if (!GetMessage(&msg, win->hwnd, 0, 0))
                        break;
                TranslateMessage(&msg);
                DispatchMessage(&msg);
        }

        for (int i = ARRAY_COUNT(modules); i --> 0;)
        {
                modules[i].teardown_func();
        }

        return 0;
}