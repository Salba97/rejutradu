# A plane class that displays a single color.
class ColoredPlane < Plane
  def initialize(color, viewport = nil)
    super(viewport)
    self.bitmap = Bitmap.new(32, 32)
    setPlaneColor(color)
  end

  def dispose
    self.bitmap.dispose if self.bitmap
    super
  end

  def update
  end

  def setPlaneColor(value)
    self.bitmap.fill_rect(0, 0, self.bitmap.width, self.bitmap.height, value)
  end
end

# A plane class that supports animated images.
class AnimatedPlane < Plane
  def initialize(viewport)
    super(viewport)
    @bitmap = nil
  end

  def dispose
    clearBitmaps()
    super
  end

  def update
    if @bitmap
      @bitmap.update
      self.bitmap = @bitmap.bitmap
    end
  end

  def clearBitmaps
    @bitmap.dispose if @bitmap
    @bitmap = nil
    self.bitmap = nil if !self.disposed?
  end

  def setPanorama(file, hue = 0)
    clearBitmaps()
    return if file == nil

    @bitmap = AnimatedBitmap.new("Graphics/Panoramas/" + file, hue)
  end

  def setFog(file, hue = 0)
    clearBitmaps()
    return if file == nil

    @bitmap = AnimatedBitmap.new("Graphics/Fogs/" + file, hue)
  end

  def setBitmap(file, hue = 0)
    clearBitmaps()
    return if file == nil

    @bitmap = AnimatedBitmap.new(file, hue)
  end
end
