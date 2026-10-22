"""Genera el diagrama del pipeline CI/CD de FitCore (PNG) para el reporte del RA.

Topologia real declarada en .github/workflows/ci-cd.yml:
  entorno -> [calidad, pruebas, api] (en paralelo)
  construye -> needs: [calidad, pruebas]
  despliegue -> needs: [construye, api]  + if: main && push
"""
from PIL import Image, ImageDraw, ImageFont

W, H = 2300, 1210
AZUL = (30, 64, 175)
AZUL_SUAVE = (219, 234, 254)
AZUL_BORDE = (59, 130, 246)
VERDE = (22, 101, 52)
VERDE_SUAVE = (220, 252, 231)
GRIS = (68, 68, 68)
GRIS_SUAVE = (243, 244, 246)
GRIS_BORDE = (209, 213, 219)
BLANCO = (255, 255, 255)
NARANJA = (154, 52, 18)
NARANJA_SUAVE = (255, 237, 213)
GRIS_TXT = (107, 114, 128)

F = r"C:\Windows\Fonts"


def fuente(nombre, tam):
    return ImageFont.truetype(f"{F}\\{nombre}", tam)


f_titulo = fuente("segoeuib.ttf", 46)
f_sub = fuente("segoeui.ttf", 26)
f_box_tit = fuente("segoeuib.ttf", 26)
f_box_cmd = fuente("consola.ttf", 19)
f_box_num = fuente("segoeuib.ttf", 28)
f_sec = fuente("segoeuib.ttf", 25)
f_art = fuente("segoeui.ttf", 19)
f_art_f = fuente("seguisb.ttf", 19)
f_nota = fuente("segoeui.ttf", 20)
f_nota_f = fuente("seguisb.ttf", 20)
f_ch = fuente("segoeui.ttf", 21)
f_dur = fuente("seguisb.ttf", 21)

img = Image.new("RGB", (W, H), BLANCO)
d = ImageDraw.Draw(img)


def multilinea(x, y, lineas, fuente_, color, salto):
    for i, l in enumerate(lineas):
        d.text((x, y + i * salto), l, font=fuente_, fill=color)
    return y + len(lineas) * salto


# ------------------------------------------------------------------ encabezado
d.text((60, 42), "FitCore - Pipeline de Integracion, Liberacion y Despliegue Continuo",
       font=f_titulo, fill=AZUL)
d.text((62, 104), "GitHub Actions  |  .github/workflows/ci-cd.yml  |  rama main  |  version 1.0.0+1",
       font=f_sub, fill=GRIS)
d.line([(60, 155), (W - 60, 155)], fill=AZUL, width=4)

# ----------------------------------------------------------------- disparadores
y0 = 250
d.rounded_rectangle([60, y0, 385, y0 + 470], radius=18, fill=AZUL_SUAVE, outline=AZUL_BORDE, width=3)
d.text((86, y0 + 20), "DISPARADORES", font=f_sec, fill=AZUL)
multilinea(86, y0 + 66, [
    "push  ->  main / develop",
    "pull_request  ->  main",
    "workflow_dispatch",
    "(ejecucion manual)",
], f_ch, GRIS, 34)
d.line([(86, y0 + 216), (359, y0 + 216)], fill=AZUL_BORDE, width=2)
multilinea(86, y0 + 234, [
    "concurrency:",
    "  group: fitcore-<ref>",
    "  cancel-in-progress: true",
    "",
    "Ejecucion limpia en",
    "ubuntu-latest",
], f_ch, GRIS, 31)

# ------------------------------------------------------------------ etapa base
BX, BY, BW, BH = 430, 250, 250, 320


def etapa_base(x, y, num, titulo, sub, cmds, dur, art, art2=None):
    d.rounded_rectangle([x, y, x + BW, y + BH], radius=14, fill=BLANCO, outline=AZUL_BORDE, width=3)
    d.rounded_rectangle([x, y, x + BW, y + 70], radius=14, fill=AZUL)
    d.rectangle([x, y + 56, x + BW, y + 70], fill=AZUL)
    d.text((x + 18, y + 20), num, font=f_box_num, fill=BLANCO)
    d.text((x + 56, y + 24), titulo, font=f_box_tit, fill=BLANCO)
    multilinea(x + 16, y + 88, sub.split("\n"), f_box_cmd, GRIS, 28)
    d.line([(x + 16, y + 152), (x + BW - 16, y + 152)], fill=GRIS_BORDE, width=2)
    multilinea(x + 16, y + 168, cmds, f_box_cmd, AZUL, 26)
    d.text((x + 16, y + 232), dur, font=f_dur, fill=VERDE)
    ay = y + BH + 18
    d.rounded_rectangle([x, ay, x + BW, ay + 84], radius=12, fill=VERDE_SUAVE,
                        outline=(134, 239, 172), width=2)
    d.text((x + 14, ay + 10), art, font=f_art_f, fill=VERDE)
    if art2:
        d.text((x + 14, ay + 40), art2, font=f_art, fill=VERDE)


etapa_base(BX, BY, "1", "ENTORNO", "Preparar entorno\nde liberacion",
           ["Java 17", "Flutter 3.47.5", "flutter pub get"], "34 s",
           "artifact: pub-deps")

# ------------------------------------------------- grupo de validaciones paralelas
GX, GY, GW = 760, 250, 420
d.rounded_rectangle([GX, GY, GX + GW, GY + 560], radius=16, fill=(248, 250, 252),
                    outline=AZUL_BORDE, width=3)
d.text((GX + 22, GY + 16), "VALIDACIONES EN PARALELO", font=f_sec, fill=AZUL)
d.text((GX + 22, GY + 48), "needs: entorno   (se inician a la vez)", font=f_art, fill=GRIS_TXT)

PARA = [
    ("2", "CALIDAD", "Analisis estatico y formato", ["dart format", "flutter analyze"], "38 s"),
    ("3", "PRUEBAS", "Pruebas y cobertura", ["flutter test", "--coverage"], "52 s"),
    ("4", "API", "Contrato de API (Newman)", ["newman run", "coleccion FitCore"], "17 s"),
]
iy = GY + 90
for num, tit, desc, cmds, dur in PARA:
    d.rounded_rectangle([GX + 22, iy, GX + GW - 22, iy + 140], radius=12, fill=BLANCO,
                        outline=GRIS_BORDE, width=2)
    d.ellipse([GX + 38, iy + 18, GX + 74, iy + 54], fill=AZUL)
    d.text((GX + 48, iy + 22), num, font=f_box_num, fill=BLANCO)
    d.text((GX + 86, iy + 18), tit, font=f_box_tit, fill=AZUL)
    d.text((GX + 38, iy + 60), desc, font=f_art, fill=GRIS)
    d.text((GX + 38, iy + 88), "  ·  ".join(cmds), font=f_box_cmd, fill=GRIS_TXT)
    d.text((GX + GW - 110, iy + 88), dur, font=f_dur, fill=VERDE)
    iy += 152

# ------------------------------------------------------- construccion y despliegue
CX, DY = 1240, 250
etapa_base(CX, DY, "5", "CONSTRUYE", "Compilar APK\nde liberacion",
           ["flutter build apk", "--release", "--dart-define"], "333 s",
           "artifact: fitcore-apk", "app-release.apk (55,2 MB)")

EX = 1560
etapa_base(EX, DY, "6", "DESPLIEGA", "Publicar version\nen GitHub Releases",
           ["softprops/", "gh-release"], "13 s",
           "Release: v1.0.0+<build>", "solo en main y con push")

# --------------------------------------------------------------------- flechas
ym = BY + 160


def flecha(x1, y1, x2, y2):
    d.line([(x1, y1), (x2, y2)], fill=AZUL, width=5)
    if x2 > x1:
        d.polygon([(x2, y2), (x2 - 18, y2 - 12), (x2 - 18, y2 + 12)], fill=AZUL)
    else:
        d.polygon([(x2, y2), (x2 + 18, y2 - 12), (x2 + 18, y2 + 12)], fill=AZUL)


flecha(385, ym, BX, ym)
flecha(BX + BW, ym, GX, ym)
flecha(GX + GW, ym, CX, ym)
flecha(CX + BW, ym, EX, ym)

def etiqueta(x_centro, texto):
    ancho = d.textlength(texto, font=f_art)
    d.text((x_centro - ancho / 2, ym + 28), texto, font=f_art, fill=GRIS_TXT)


etiqueta((BX + BW + GX) / 2, "needs: entorno")
etiqueta((GX + GW + CX) / 2, "needs: [calidad, pruebas]")
etiqueta((CX + BW + EX) / 2, "needs: [construye, api]")

# --------------------------------------------------------------- notas de reglas
NY = 860
d.rounded_rectangle([60, NY, W - 60, NY + 290], radius=16, fill=GRIS_SUAVE,
                    outline=GRIS_BORDE, width=2)
d.text((88, NY + 18), "REGLAS DE DEPENDENCIA, PUBLICACION Y TIEMPOS", font=f_sec, fill=GRIS)

reglas = [
    "Las etapas «calidad», «pruebas» y «api» dependen solo de «entorno»: se ejecutan en paralelo y no dependen entre si.",
    "«construye» depende de «calidad» y «pruebas»; «despliegue» depende de «construye» y de «api» (la validacion del contrato sigue vigente al publicar).",
    "El despliegue solo se ejecuta en la rama main y con el evento push; una pull request o una rama de trabajo nunca publican una version.",
    "Si la etapa «api» falla, «despliegue» se omite: nunca se publica una version sin contrato de API validado.",
]
y = NY + 62
for r in reglas:
    d.ellipse([88, y + 8, 98, y + 18], fill=AZUL)
    d.text((112, y), r, font=f_nota, fill=GRIS)
    y += 40

d.text((88, y + 12),
       "Tiempo de reloj de la linea de produccion: 441 s (7 min 21 s)  |  suma de las seis etapas: 487 s  |  "
       "compilacion del APK: 333 s (69 % del tiempo de computo).",
       font=f_nota_f, fill=NARANJA)

salida = r"C:\Users\Any Ovando\Documents\FitCore_Limpio\docs\capturas\diagrama_pipeline.png"
img.save(salida)
print("Diagrama generado:", salida)
