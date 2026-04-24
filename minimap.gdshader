shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.45;
uniform float smoothness : hint_range(0.0, 0.1) = 0.01;

void fragment() {
    // Le coordinate UV (0-1) si riferiscono all'intero TextureRect
    // La cornice probabilmente occupa una porzione specifica
    // Dobbiamo mappare le UV della cornice alle UV totali

    // Supponiamo che la cornice sia centrata e occupi il 90% della texture
    float frame_size = 0.9; // Regola questo valore
    float frame_offset = (1.0 - frame_size) / 2.0;

    // Mappa le UV della texture alle UV della cornice
    vec2 frame_uv = (UV - frame_offset) / frame_size;

    // Se siamo fuori dalla cornice, scarta
    if (frame_uv.x < 0.0 || frame_uv.x > 1.0 || frame_uv.y < 0.0 || frame_uv.y > 1.0) {
        discard;
    }

    // Calcola il cerchio nelle coordinate della cornice
    float dist = distance(frame_uv, vec2(0.5, 0.5));

    if (dist > radius) {
        discard;
    }

    COLOR = texture(TEXTURE, UV);
}