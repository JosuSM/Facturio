#!/usr/bin/env python3
"""
Gerador de ícones de aplicação para Facturio
Cria ícones com gradiente teal e design moderno para Android e iOS
"""

from PIL import Image, ImageDraw
import os
import sys

# Cores do tema Facturio
PRIMARY_COLOR = (15, 118, 110)  # #0F766E - Teal escuro
SECONDARY_COLOR = (20, 184, 166)  # #14B8A6 - Teal claro
WHITE = (255, 255, 255, 255)

def create_gradient_background(size, corner_radius=0):
    """Cria um fundo com gradiente diagonal - versão otimizada"""
    # Criar imagem com gradiente
    pixels = []
    for y in range(size):
        row = []
        for x in range(size):
            # Calcular posição diagonal (0.0 a 1.0)
            ratio = (x + y) / (2 * size)
            
            # Interpolar cores
            r = int(PRIMARY_COLOR[0] + (SECONDARY_COLOR[0] - PRIMARY_COLOR[0]) * ratio)
            g = int(PRIMARY_COLOR[1] + (SECONDARY_COLOR[1] - PRIMARY_COLOR[1]) * ratio)
            b = int(PRIMARY_COLOR[2] + (SECONDARY_COLOR[2] - PRIMARY_COLOR[2]) * ratio)
            
            row.append((r, g, b, 255))
        pixels.append(row)
    
    # Construir imagem pixel por pixel é lento, usar ImageDraw é mais eficiente
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    # Preencher com gradiente linha por linha
    for y in range(size):
        for x in range(size):
            ratio = (x + y) / (2 * size)
            r = int(PRIMARY_COLOR[0] + (SECONDARY_COLOR[0] - PRIMARY_COLOR[0]) * ratio)
            g = int(PRIMARY_COLOR[1] + (SECONDARY_COLOR[1] - PRIMARY_COLOR[1]) * ratio)
            b = int(PRIMARY_COLOR[2] + (SECONDARY_COLOR[2] - PRIMARY_COLOR[2]) * ratio)
            img.putpixel((x, y), (r, g, b, 255))
    
    # Aplicar cantos arredondados se necessário
    if corner_radius > 0:
        mask = Image.new('L', (size, size), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.rounded_rectangle(
            [(0, 0), (size - 1, size - 1)],
            radius=corner_radius,
            fill=255
        )
        img.putalpha(mask)
    
    return img

def draw_receipt_icon(img, size):
    """Desenha um ícone de recibo estilizado"""
    draw = ImageDraw.Draw(img)
    
    # Dimensões do recibo
    margin = size * 0.20
    receipt_width = size - (2 * margin)
    receipt_height = size - (2 * margin)
    
    left = margin
    top = margin
    right = left + receipt_width
    bottom = top + receipt_height
    
    # Corpo do recibo (retângulo arredondado)
    corner = size * 0.08
    draw.rounded_rectangle(
        [(left, top), (right, bottom)],
        radius=corner,
        fill=WHITE,
        outline=None
    )
    
    # Linhas horizontais simulando texto
    line_margin = size * 0.28
    line_width = receipt_width * 0.6
    line_height = size * 0.04
    line_spacing = size * 0.10
    
    line_color = PRIMARY_COLOR + (255,)
    
    for i in range(4):
        line_top = top + line_margin + (i * line_spacing)
        draw.rounded_rectangle(
            [(left + (receipt_width - line_width) / 2, line_top),
             (left + (receipt_width + line_width) / 2, line_top + line_height)],
            radius=line_height / 2,
            fill=line_color
        )
    
    return img

def create_icon(size, corner_radius=0):
    """Cria um ícone completo"""
    img = create_gradient_background(size, corner_radius)
    img = draw_receipt_icon(img, size)
    return img

def generate_android_icons(base_dir):
    """Gera ícones para Android em todas as densidades"""
    densities = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    
    print("Gerando ícones Android...")
    try:
        for folder, size in densities.items():
            icon = create_icon(size)
            output_path = os.path.join(base_dir, 'android', 'app', 'src', 'main', 'res', folder, 'ic_launcher.png')
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            icon.save(output_path, 'PNG')
            print(f"  ✓ {folder}/ic_launcher.png ({size}x{size})")
    except Exception as e:
        print(f"  ✗ Erro ao gerar ícones Android: {e}")
        return False
    return True

def generate_ios_icons(base_dir):
    """Gera ícones para iOS em todos os tamanhos necessários"""
    sizes = [
        ('Icon-App-20x20@1x.png', 20),
        ('Icon-App-20x20@2x.png', 40),
        ('Icon-App-20x20@3x.png', 60),
        ('Icon-App-29x29@1x.png', 29),
        ('Icon-App-29x29@2x.png', 58),
        ('Icon-App-29x29@3x.png', 87),
        ('Icon-App-40x40@1x.png', 40),
        ('Icon-App-40x40@2x.png', 80),
        ('Icon-App-40x40@3x.png', 120),
        ('Icon-App-60x60@2x.png', 120),
        ('Icon-App-60x60@3x.png', 180),
        ('Icon-App-76x76@1x.png', 76),
        ('Icon-App-76x76@2x.png', 152),
        ('Icon-App-83.5x83.5@2x.png', 167),
        ('Icon-App-1024x1024@1x.png', 1024),
    ]
    
    print("\nGerando ícones iOS...")
    try:
        ios_base = os.path.join(base_dir, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
        os.makedirs(ios_base, exist_ok=True)
        
        for filename, size in sizes:
            # iOS requer cantos arredondados em certos tamanhos
            corner_ratio = 0.2237  # 22.37% é o raio padrão do iOS
            corner_radius = int(size * corner_ratio)
            
            icon = create_icon(size, corner_radius)
            output_path = os.path.join(ios_base, filename)
            icon.save(output_path, 'PNG')
            print(f"  ✓ {filename} ({size}x{size})")
    except Exception as e:
        print(f"  ✗ Erro ao gerar ícones iOS: {e}")
        return False
    return True

def generate_asset_icons(base_dir):
    """Gera ícones para assets/icons"""
    sizes = [16, 32, 48, 64, 128, 192, 256, 512]
    
    print("\nGerando ícones assets...")
    try:
        assets_base = os.path.join(base_dir, 'assets', 'icons')
        os.makedirs(assets_base, exist_ok=True)
        
        for size in sizes:
            icon = create_icon(size)
            output_path = os.path.join(assets_base, f'icon-{size}.png')
            icon.save(output_path, 'PNG')
            print(f"  ✓ icon-{size}.png ({size}x{size})")
    except Exception as e:
        print(f"  ✗ Erro ao gerar ícones assets: {e}")
        return False
    return True

if __name__ == '__main__':
    # Usar diretório do script como base
    base_dir = os.path.dirname(os.path.abspath(__file__))
    
    print("=" * 50)
    print("Gerador de Ícones Facturio")
    print("=" * 50)
    
    all_success = True
    all_success = generate_android_icons(base_dir) and all_success
    all_success = generate_ios_icons(base_dir) and all_success
    all_success = generate_asset_icons(base_dir) and all_success
    
    print("\n" + "=" * 50)
    if all_success:
        print("✓ Todos os ícones foram gerados com sucesso!")
        sys.exit(0)
    else:
        print("✗ Alguns ícones falharam. Veja os erros acima.")
        sys.exit(1)
    print("=" * 50)
