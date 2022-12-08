
import ee
import numpy as np

###################################################
def test_eeBatchExport():

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    s2 = ee.ImageCollection('COPERNICUS/S2_HARMONIZED')
    geometry = ee.Geometry.Polygon([[
      [82.60642647743225, 27.163504378052510],
      [82.60984897613525, 27.161852990137700],
      [82.61088967323303, 27.163695288375266],
      [82.60757446289062, 27.165174832309270]
    ]])

    filtered = s2 \
        .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 30)) \
        .filter(ee.Filter.date('2019-02-01', '2019-03-01')) \
        .filter(ee.Filter.bounds(geometry))

    withNdvi = filtered \
        .map(maskS2clouds) \
        .map(addNDVI)

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    composite = withNdvi.median()
    ndvi = composite.select('ndvi')

    stats = ndvi.reduceRegion(**{
      'reducer'   : ee.Reducer.mean(),
      'geometry'  : geometry,
      'scale'     : 10,
      'maxPixels' : 1e10
      })

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print("\nstats.get('ndvi').getInfo()\n")
    print(   stats.get('ndvi').getInfo()   )

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( None )

##### ##### ##### ##### #####
def maskS2clouds(image):
  qa = image.select('QA60')
  cloudBitMask = 1 << 10
  cirrusBitMask = 1 << 11
  mask = qa.bitwiseAnd(cloudBitMask).eq(0).And(
             qa.bitwiseAnd(cirrusBitMask).eq(0))
  return image.updateMask(mask) \
      .select("B.*") \
      .copyProperties(image, ["system:time_start"])

def addNDVI(image):
  ndvi = image.normalizedDifference(['B8', 'B4']).rename('ndvi')
  return image.addBands(ndvi)
