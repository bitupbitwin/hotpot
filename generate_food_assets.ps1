Add-Type -AssemblyName System.Drawing

$outDir = Join-Path $PSScriptRoot "assets/images"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function New-IconCanvas {
  $bmp = New-Object System.Drawing.Bitmap 512, 512
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.Clear([System.Drawing.Color]::Transparent)
  return @{ Bitmap = $bmp; Graphics = $g }
}

function Save-Icon($canvas, [string]$name) {
  $path = Join-Path $outDir $name
  $canvas.Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $canvas.Graphics.Dispose()
  $canvas.Bitmap.Dispose()
}

function Brush([string]$hex) {
  return New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function Pen([string]$hex, [float]$width) {
  $p = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml($hex)), $width
  $p.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $p.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $p.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  return $p
}

function Draw-Plate($g) {
  $shadow = Brush "#33000000"
  $rim = Brush "#F6F2E6"
  $inner = Brush "#DED5C2"
  $g.FillEllipse($shadow, 96, 318, 320, 58)
  $g.FillEllipse($rim, 100, 300, 312, 70)
  $g.FillEllipse($inner, 134, 315, 244, 38)
  $shadow.Dispose(); $rim.Dispose(); $inner.Dispose()
}

function Draw-RoundedRect($g, $brush, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddArc($x, $y, $r, $r, 180, 90)
  $path.AddArc($x + $w - $r, $y, $r, $r, 270, 90)
  $path.AddArc($x + $w - $r, $y + $h - $r, $r, $r, 0, 90)
  $path.AddArc($x, $y + $h - $r, $r, $r, 90, 90)
  $path.CloseFigure()
  $g.FillPath($brush, $path)
  $path.Dispose()
}

function Draw-Ribbon($g, $points, [string]$fill, [string]$stroke) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddClosedCurve($points, 0.42)
  $b = Brush $fill
  $p = Pen $stroke 7
  $g.FillPath($b, $path)
  $g.DrawPath($p, $path)
  $b.Dispose(); $p.Dispose(); $path.Dispose()
}

function Icon-Maodu {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  $fills = @("#B9B4A6", "#D4CAB7", "#AFA99B")
  for ($i = 0; $i -lt 5; $i++) {
    $x = 134 + $i * 48
    $pts = @(
      [System.Drawing.PointF]::new($x, 158),
      [System.Drawing.PointF]::new($x + 38, 150),
      [System.Drawing.PointF]::new($x + 54, 292),
      [System.Drawing.PointF]::new($x + 9, 306)
    )
    Draw-Ribbon $g $pts $fills[$i % 3] "#665F55"
    $p = Pen "#EFE8D8" 4
    for ($j = 0; $j -lt 5; $j++) {
      $xx = $x + 9 + $j * 8
      $g.DrawLine($p, $xx, 172, $xx + 5, 286)
    }
    $p.Dispose()
  }
  Save-Icon $c "1_maodu.png"
}

function Icon-DuckIntestine {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  $tube = Pen "#F5B5AE" 24
  $edge = Pen "#A75A52" 31
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddBezier(130, 270, 178, 150, 272, 150, 226, 258)
  $path.AddBezier(226, 258, 188, 350, 348, 346, 332, 236)
  $path.AddBezier(332, 236, 320, 144, 166, 190, 246, 310)
  $g.DrawPath($edge, $path)
  $g.DrawPath($tube, $path)
  $shine = Pen "#FFE5DF" 5
  $g.DrawPath($shine, $path)
  $tube.Dispose(); $edge.Dispose(); $shine.Dispose(); $path.Dispose()
  Save-Icon $c "2_duchang.png"
}

function Icon-Beef {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  for ($i = 0; $i -lt 4; $i++) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $x = 126 + $i * 58
    $path.AddClosedCurve(@(
      [System.Drawing.PointF]::new($x, 186 + ($i % 2) * 22),
      [System.Drawing.PointF]::new($x + 58, 158 + $i * 3),
      [System.Drawing.PointF]::new($x + 100, 224),
      [System.Drawing.PointF]::new($x + 48, 292),
      [System.Drawing.PointF]::new($x - 20, 258)
    ), 0.45)
    $b = Brush "#C92E3C"; $p = Pen "#7C1620" 6
    $g.FillPath($b, $path); $g.DrawPath($p, $path)
    $marble = Pen "#F7D2C6" 5
    $g.DrawBezier($marble, $x + 8, 224, $x + 38, 190, $x + 58, 270, $x + 88, 220)
    $g.DrawBezier($marble, $x + 18, 254, $x + 50, 235, $x + 68, 302, $x + 98, 260)
    $b.Dispose(); $p.Dispose(); $marble.Dispose(); $path.Dispose()
  }
  Save-Icon $c "3_niuniu.png"
}

function Icon-BeefBall {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  $colors = @("#8A4B2B", "#A65E35", "#734026", "#B56D3C")
  $spots = Brush "#D6A56F"
  $positions = @(@(154,196), @(228,170), @(294,206), @(196,260), @(274,276))
  for ($i = 0; $i -lt $positions.Count; $i++) {
    $x = $positions[$i][0]; $y = $positions[$i][1]
    $b = Brush $colors[$i % $colors.Count]
    $g.FillEllipse($b, $x, $y, 76, 76)
    $g.FillEllipse($spots, $x + 18, $y + 18, 14, 10)
    $g.FillEllipse($spots, $x + 45, $y + 34, 10, 12)
    $b.Dispose()
  }
  $spots.Dispose()
  Save-Icon $c "4_niuwan.png"
}

function Icon-ShrimpPaste {
  $c = New-IconCanvas; $g = $c.Graphics
  $tray = Brush "#D9F0FA"; $rim = Pen "#5FAFC7" 8
  Draw-RoundedRect $g $tray 112 286 288 70 36
  $g.DrawLine($rim, 136, 322, 376, 322)
  $tray.Dispose(); $rim.Dispose()
  for ($i = 0; $i -lt 3; $i++) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $x = 146 + $i * 74
    $path.AddClosedCurve(@(
      [System.Drawing.PointF]::new($x, 232),
      [System.Drawing.PointF]::new($x + 44, 194),
      [System.Drawing.PointF]::new($x + 94, 232),
      [System.Drawing.PointF]::new($x + 70, 292),
      [System.Drawing.PointF]::new($x + 8, 286)
    ), 0.55)
    $b = Brush "#F5A0A7"; $p = Pen "#D76D76" 5
    $g.FillPath($b, $path); $g.DrawPath($p, $path)
    $hi = Pen "#FFE0E4" 5
    $g.DrawBezier($hi, $x + 20, 238, $x + 44, 218, $x + 66, 220, $x + 78, 242)
    $b.Dispose(); $p.Dispose(); $hi.Dispose(); $path.Dispose()
  }
  Save-Icon $c "5_xiahua.png"
}

function Icon-Tofu {
  $c = New-IconCanvas; $g = $c.Graphics
  Draw-Plate $g
  $front = Brush "#F3E19A"; $top = Brush "#FFF6C5"; $side = Brush "#D8B85E"; $line = Pen "#B99D4C" 5
  $blocks = @(@(160,196), @(238,176), @(236,254), @(314,226))
  foreach ($pt in $blocks) {
    $x = $pt[0]; $y = $pt[1]
    $g.FillRectangle($side, $x + 18, $y + 18, 74, 74)
    $g.FillRectangle($front, $x, $y + 22, 78, 72)
    $g.FillRectangle($top, $x, $y, 78, 32)
    $g.DrawRectangle($line, $x, $y, 78, 94)
  }
  $front.Dispose(); $top.Dispose(); $side.Dispose(); $line.Dispose()
  Save-Icon $c "6_doufu.png"
}

function Icon-Enoki {
  $c = New-IconCanvas; $g = $c.Graphics
  $stem = Pen "#F3E6C9" 8
  $cap = Brush "#D6B27A"
  $base = Brush "#EEE0BE"
  for ($i = 0; $i -lt 17; $i++) {
    $x = 142 + $i * 14
    $topY = 136 + [Math]::Abs(8 - $i) * 8
    $g.DrawBezier($stem, $x + 10, 342, $x - 2, 270, $x + 18, 204, $x + 8, $topY + 28)
    $g.FillEllipse($cap, $x - 2, $topY, 28, 28)
  }
  $g.FillEllipse($base, 146, 318, 220, 58)
  $stem.Dispose(); $cap.Dispose(); $base.Dispose()
  Save-Icon $c "7_jinzhengu.png"
}

function Icon-Kuanfen {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  $fill = Brush "#D7C3A0"; $edge = Pen "#9B805A" 6; $hi = Pen "#FFF1CE" 5
  for ($i = 0; $i -lt 5; $i++) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $x = 126 + $i * 42
    $path.AddBezier($x, 170, $x + 94, 142, $x - 24, 280, $x + 86, 314)
    $path.AddBezier($x + 86, 314, $x + 34, 334, $x + 16, 282, $x + 42, 246)
    $path.AddBezier($x + 42, 246, $x + 60, 216, $x - 10, 212, $x, 170)
    $path.CloseFigure()
    $g.FillPath($fill, $path); $g.DrawPath($edge, $path)
    $g.DrawBezier($hi, $x + 14, 196, $x + 72, 188, $x + 6, 270, $x + 68, 294)
    $path.Dispose()
  }
  $fill.Dispose(); $edge.Dispose(); $hi.Dispose()
  Save-Icon $c "8_kuanfen.png"
}

function Icon-QuailEgg {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  $egg = Brush "#F7E2C2"; $spot = Brush "#704B36"; $edge = Pen "#C99F76" 5
  $positions = @(@(148,192), @(220,168), @(292,196), @(184,268), @(268,276))
  foreach ($pt in $positions) {
    $x = $pt[0]; $y = $pt[1]
    $g.FillEllipse($egg, $x, $y, 74, 96)
    $g.DrawEllipse($edge, $x, $y, 74, 96)
    $g.FillEllipse($spot, $x + 18, $y + 24, 10, 8)
    $g.FillEllipse($spot, $x + 42, $y + 48, 12, 10)
    $g.FillEllipse($spot, $x + 28, $y + 70, 8, 8)
  }
  $egg.Dispose(); $spot.Dispose(); $edge.Dispose()
  Save-Icon $c "9_anchundun.png"
}

function Icon-Lettuce {
  $c = New-IconCanvas; $g = $c.Graphics
  $colors = @("#52C76A", "#3DAE58", "#75D784", "#2D9546")
  for ($i = 0; $i -lt 8; $i++) {
    $angle = ($i * 45 - 90) * [Math]::PI / 180
    $cx = 256 + [Math]::Cos($angle) * 58
    $cy = 260 + [Math]::Sin($angle) * 34
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddClosedCurve(@(
      [System.Drawing.PointF]::new($cx, $cy - 94),
      [System.Drawing.PointF]::new($cx + 68, $cy - 54),
      [System.Drawing.PointF]::new($cx + 48, $cy + 54),
      [System.Drawing.PointF]::new($cx, $cy + 86),
      [System.Drawing.PointF]::new($cx - 58, $cy + 42),
      [System.Drawing.PointF]::new($cx - 62, $cy - 50)
    ), 0.52)
    $b = Brush $colors[$i % $colors.Count]
    $g.FillPath($b, $path)
    $vein = Pen "#D8F0C0" 4
    $g.DrawLine($vein, $cx, $cy + 60, $cx, $cy - 62)
    $b.Dispose(); $vein.Dispose(); $path.Dispose()
  }
  $core = Brush "#D5E46E"
  $g.FillEllipse($core, 214, 226, 84, 76)
  $core.Dispose()
  Save-Icon $c "10_shengcai.png"
}

function Icon-Rolls([string]$file, [string]$fill, [string]$stroke) {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  for ($i = 0; $i -lt 5; $i++) {
    $x = 126 + $i * 50
    $b = Brush $fill; $p = Pen $stroke 6; $hi = Pen "#FFE1D6" 4
    $g.FillEllipse($b, $x, 178, 88, 76)
    $g.DrawEllipse($p, $x, 178, 88, 76)
    $g.DrawArc($hi, $x + 18, 194, 48, 38, 200, 260)
    $b.Dispose(); $p.Dispose(); $hi.Dispose()
  }
  Save-Icon $c $file
}

function Icon-BeefTongue {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  $b = Brush "#C96570"; $p = Pen "#8A2F39" 7; $hi = Pen "#F3B0B8" 5
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddClosedCurve(@(
    [System.Drawing.PointF]::new(166, 220),
    [System.Drawing.PointF]::new(230, 142),
    [System.Drawing.PointF]::new(340, 170),
    [System.Drawing.PointF]::new(342, 278),
    [System.Drawing.PointF]::new(242, 314),
    [System.Drawing.PointF]::new(162, 276)
  ), 0.48)
  $g.FillPath($b, $path); $g.DrawPath($p, $path)
  $g.DrawBezier($hi, 206, 218, 252, 180, 306, 196, 318, 246)
  $b.Dispose(); $p.Dispose(); $hi.Dispose(); $path.Dispose()
  Save-Icon $c "12_niushe.png"
}

function Icon-Strips([string]$file, [string]$fill, [string]$stroke) {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  for ($i = 0; $i -lt 6; $i++) {
    $x = 132 + $i * 42
    $pts = @(
      [System.Drawing.PointF]::new($x, 172),
      [System.Drawing.PointF]::new($x + 32, 160),
      [System.Drawing.PointF]::new($x + 54, 292),
      [System.Drawing.PointF]::new($x + 16, 306)
    )
    Draw-Ribbon $g $pts $fill $stroke
  }
  Save-Icon $c $file
}

function Icon-FishFillet {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  for ($i = 0; $i -lt 4; $i++) {
    $x = 138 + $i * 58
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddClosedCurve(@(
      [System.Drawing.PointF]::new($x, 208),
      [System.Drawing.PointF]::new($x + 72, 178),
      [System.Drawing.PointF]::new($x + 112, 236),
      [System.Drawing.PointF]::new($x + 56, 292),
      [System.Drawing.PointF]::new($x - 14, 256)
    ), 0.45)
    $b = Brush "#F6E2D2"; $p = Pen "#CA8A72" 5; $line = Pen "#F39A8B" 4
    $g.FillPath($b, $path); $g.DrawPath($p, $path)
    $g.DrawBezier($line, $x + 18, 234, $x + 44, 204, $x + 70, 270, $x + 98, 226)
    $b.Dispose(); $p.Dispose(); $line.Dispose(); $path.Dispose()
  }
  Save-Icon $c "15_yupian.png"
}

function Icon-Shrimp {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  for ($i = 0; $i -lt 3; $i++) {
    $x = 150 + $i * 70
    $body = Pen "#FF7A2F" 24; $edge = Pen "#C34E1C" 30
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddBezier($x, 246, $x + 30, 168, $x + 116, 192, $x + 78, 278)
    $g.DrawPath($edge, $path); $g.DrawPath($body, $path)
    $body.Dispose(); $edge.Dispose(); $path.Dispose()
  }
  Save-Icon $c "16_xianxia.png"
}

function Icon-Leafy([string]$file, [string]$fill) {
  $c = New-IconCanvas; $g = $c.Graphics
  $b = Brush $fill; $vein = Pen "#D8F0C0" 5
  for ($i = 0; $i -lt 7; $i++) {
    $x = 142 + $i * 36
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddClosedCurve(@(
      [System.Drawing.PointF]::new($x, 318),
      [System.Drawing.PointF]::new($x + 8, 198),
      [System.Drawing.PointF]::new($x + 54, 150),
      [System.Drawing.PointF]::new($x + 82, 230),
      [System.Drawing.PointF]::new($x + 48, 342)
    ), 0.45)
    $g.FillPath($b, $path); $g.DrawLine($vein, $x + 40, 316, $x + 44, 184)
    $path.Dispose()
  }
  $b.Dispose(); $vein.Dispose()
  Save-Icon $c $file
}

function Icon-Shiitake {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  $cap = Brush "#8C5A35"; $stem = Brush "#E8D2A7"; $dot = Brush "#DAB57E"
  $positions = @(@(154,190), @(236,164), @(302,216), @(196,262), @(278,288))
  foreach ($pt in $positions) {
    $x = $pt[0]; $y = $pt[1]
    $g.FillRectangle($stem, $x + 28, $y + 42, 22, 58)
    $g.FillEllipse($cap, $x, $y, 84, 64)
    $g.FillEllipse($dot, $x + 22, $y + 18, 12, 8)
    $g.FillEllipse($dot, $x + 52, $y + 28, 10, 8)
  }
  $cap.Dispose(); $stem.Dispose(); $dot.Dispose()
  Save-Icon $c "19_xianggu.png"
}

function Icon-Potato {
  $c = New-IconCanvas; $g = $c.Graphics; Draw-Plate $g
  for ($i = 0; $i -lt 5; $i++) {
    $x = 136 + $i * 52; $y = 190 + ($i % 2) * 36
    $b = Brush "#D59B56"; $p = Pen "#9C6735" 5; $spot = Brush "#A36D3E"
    $g.FillEllipse($b, $x, $y, 92, 70)
    $g.DrawEllipse($p, $x, $y, 92, 70)
    $g.FillEllipse($spot, $x + 24, $y + 24, 8, 6)
    $g.FillEllipse($spot, $x + 58, $y + 36, 7, 6)
    $b.Dispose(); $p.Dispose(); $spot.Dispose()
  }
  Save-Icon $c "20_tudoupian.png"
}

Icon-Maodu
Icon-DuckIntestine
Icon-Beef
Icon-BeefBall
Icon-ShrimpPaste
Icon-Tofu
Icon-Enoki
Icon-Kuanfen
Icon-QuailEgg
Icon-Lettuce
Icon-Rolls "11_feiniu.png" "#D43842" "#821822"
Icon-BeefTongue
Icon-Rolls "13_yangrou.png" "#C85B65" "#7E2C34"
Icon-Strips "14_huanghou.png" "#D2BB8A" "#7E6F4B"
Icon-FishFillet
Icon-Shrimp
Icon-Leafy "17_youmaicai.png" "#4FC56B"
Icon-Leafy "18_wawacai.png" "#9DDC74"
Icon-Shiitake
Icon-Potato
