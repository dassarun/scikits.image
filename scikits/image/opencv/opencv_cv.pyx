# -*- python -*-

import ctypes

cimport numpy as np
import numpy as np

from cpython cimport *
from libc.stdlib cimport *
from opencv_type cimport *
from opencv_backend import *
from opencv_backend cimport *
from opencv_constants import *

from opencv_constants import *
from opencv_cv import *

from _libimport import cv
from _utilities import cvdoc

if cv is None:
    raise RuntimeError("Could not load libcv")

# setup numpy tables for this module
np.import_array()

#-------------------------------------------------------------------------------
# Useful global stuff
#-------------------------------------------------------------------------------

# a dict for cvCvtColor to get the appropriate types and shapes without
# if statements all over the place (this way is faster, cause the dict is
# created at import time)
# the order of list arguments is:
# [in_channels, out_channels, [input_dtypes]]
# out type is always the same as in type

_cvtcolor_dict = {CV_BGR2BGRA: [3, 4, [UINT8, UINT16, FLOAT32]],
                  CV_RGB2RGBA: [3, 4, [UINT8, UINT16, FLOAT32]],
                  CV_BGRA2BGR: [4, 3, [UINT8, UINT16, FLOAT32]],
                  CV_RGBA2RGB: [4, 3, [UINT8, UINT16, FLOAT32]],
                  CV_BGR2RGBA: [3, 4, [UINT8, UINT16, FLOAT32]],
                  CV_RGB2BGRA: [3, 4, [UINT8, UINT16, FLOAT32]],
                  CV_RGBA2BGR: [4, 3, [UINT8, UINT16, FLOAT32]],
                  CV_BGRA2RGB: [4, 3, [UINT8, UINT16, FLOAT32]],
                  CV_BGR2RGB: [3, 3, [UINT8, UINT16, FLOAT32]],
                  CV_RGB2BGR: [3, 3, [UINT8, UINT16, FLOAT32]],
                  CV_BGRA2RGBA: [4, 4, [UINT8, UINT16, FLOAT32]],
                  CV_RGBA2BGRA: [4, 4, [UINT8, UINT16, FLOAT32]],
                  CV_BGR2GRAY: [3, 1, [UINT8, UINT16, FLOAT32]],
                  CV_RGB2GRAY: [3, 1, [UINT8, UINT16, FLOAT32]],
                  CV_GRAY2BGR: [1, 3, [UINT8, UINT16, FLOAT32]],
                  CV_GRAY2RGB: [1, 3, [UINT8, UINT16, FLOAT32]],
                  CV_GRAY2BGRA: [1, 4, [UINT8, UINT16, FLOAT32]],
                  CV_GRAY2RGBA: [1, 4, [UINT8, UINT16, FLOAT32]],
                  CV_BGRA2GRAY: [4, 1, [UINT8, UINT16, FLOAT32]],
                  CV_RGBA2GRAY: [4, 1, [UINT8, UINT16, FLOAT32]],
                  CV_BGR2BGR565: [3, 2, [UINT8]],
                  CV_RGB2BGR565: [3, 2, [UINT8]],
                  CV_BGR5652BGR: [2, 3, [UINT8]],
                  CV_BGR5652RGB: [2, 3, [UINT8]],
                  CV_BGRA2BGR565: [4, 2, [UINT8]],
                  CV_RGBA2BGR565: [4, 2, [UINT8]],
                  CV_BGR5652BGRA: [2, 4, [UINT8]],
                  CV_BGR5652RGBA: [2, 4, [UINT8]],
                  CV_GRAY2BGR565: [1, 2, [UINT8]],
                  CV_BGR5652GRAY: [2, 1, [UINT8]],
                  CV_BGR2BGR555: [3, 2, [UINT8]],
                  CV_RGB2BGR555: [3, 2, [UINT8]],
                  CV_BGR5552BGR: [2, 3, [UINT8]],
                  CV_BGR5552RGB: [2, 3, [UINT8]],
                  CV_BGRA2BGR555: [4, 2, [UINT8]],
                  CV_RGBA2BGR555: [4, 2, [UINT8]],
                  CV_BGR5552BGRA: [2, 4, [UINT8]],
                  CV_BGR5552RGBA: [2, 4, [UINT8]],
                  CV_GRAY2BGR555: [1, 2, [UINT8]],
                  CV_BGR5552GRAY: [2, 1, [UINT8]],
                  CV_BGR2XYZ: [3, 3, [UINT8, UINT16, FLOAT32]],
                  CV_RGB2XYZ: [3, 3, [UINT8, UINT16, FLOAT32]],
                  CV_XYZ2BGR: [3, 3, [UINT8, UINT16, FLOAT32]],
                  CV_XYZ2RGB: [3, 3, [UINT8, UINT16, FLOAT32]],
                  CV_BGR2YCrCb: [3, 3, [UINT8, UINT16, FLOAT32]],
                  CV_RGB2YCrCb: [3, 3, [UINT8, UINT16, FLOAT32]],
                  CV_YCrCb2BGR: [3, 3, [UINT8, UINT16, FLOAT32]],
                  CV_YCrCb2RGB: [3, 3, [UINT8, UINT16, FLOAT32]],
                  CV_BGR2HSV: [3, 3, [UINT8, FLOAT32]],
                  CV_RGB2HSV: [3, 3, [UINT8, FLOAT32]],
                  CV_BGR2Lab: [3, 3, [UINT8, FLOAT32]],
                  CV_RGB2Lab: [3, 3, [UINT8, FLOAT32]],
                  CV_BayerBG2BGR: [1, 3, [UINT8]],
                  CV_BayerGB2BGR: [1, 3, [UINT8]],
                  CV_BayerRG2BGR: [1, 3, [UINT8]],
                  CV_BayerGR2BGR: [1, 3, [UINT8]],
                  CV_BayerBG2RGB: [1, 3, [UINT8]],
                  CV_BayerGB2RGB: [1, 3, [UINT8]],
                  CV_BayerRG2RGB: [1, 3, [UINT8]],
                  CV_BayerGR2RGB: [1, 3, [UINT8]],
                  CV_BGR2Luv: [3, 3, [UINT8, FLOAT32]],
                  CV_RGB2Luv: [3, 3, [UINT8, FLOAT32]],
                  CV_BGR2HLS: [3, 3, [UINT8, FLOAT32]],
                  CV_RGB2HLS: [3, 3, [UINT8, FLOAT32]],
                  CV_HSV2BGR: [3, 3, [UINT8, FLOAT32]],
                  CV_HSV2RGB: [3, 3, [UINT8, FLOAT32]],
                  CV_Lab2BGR: [3, 3, [UINT8, FLOAT32]],
                  CV_Lab2RGB: [3, 3, [UINT8, FLOAT32]],
                  CV_Luv2BGR: [3, 3, [UINT8, FLOAT32]],
                  CV_Luv2RGB: [3, 3, [UINT8, FLOAT32]],
                  CV_HLS2BGR: [3, 3, [UINT8, FLOAT32]],
                  CV_HLS2RGB: [3, 3, [UINT8, FLOAT32]]}


###################################
# opencv function declarations
###################################

# cvSobel
ctypedef void (*cvSobelPtr)(IplImage*, IplImage*, int, int, int)
cdef cvSobelPtr c_cvSobel
c_cvSobel = (<cvSobelPtr*><size_t>ctypes.addressof(cv.cvSobel))[0]

# cvLaplace
ctypedef void (*cvLaplacePtr)(IplImage*, IplImage*, int)
cdef cvLaplacePtr c_cvLaplace
c_cvLaplace = (<cvLaplacePtr*><size_t>ctypes.addressof(cv.cvLaplace))[0]

# cvCanny
ctypedef void (*cvCannyPtr)(IplImage*, IplImage*, double, double, int)
cdef cvCannyPtr c_cvCanny
c_cvCanny = (<cvCannyPtr*><size_t>ctypes.addressof(cv.cvCanny))[0]

# cvPreCornerDetect
ctypedef void (*cvPreCorneDetectPtr)(IplImage*, IplImage*, int)
cdef cvPreCorneDetectPtr c_cvPreCornerDetect
c_cvPreCornerDetect = (<cvPreCorneDetectPtr*><size_t>
                       ctypes.addressof(cv.cvPreCornerDetect))[0]

# cvCornerEigenValsAndVecs
ctypedef void (*cvCornerEigenValsAndVecsPtr)(IplImage*, IplImage*, int, int)
cdef cvCornerEigenValsAndVecsPtr c_cvCornerEigenValsAndVecs
c_cvCornerEigenValsAndVecs = (<cvCornerEigenValsAndVecsPtr*><size_t>
                              ctypes.addressof(cv.cvCornerEigenValsAndVecs))[0]

# cvCornerMinEigenVal
ctypedef void (*cvCornerMinEigenValPtr)(IplImage*, IplImage*, int, int)
cdef cvCornerMinEigenValPtr c_cvCornerMinEigenVal
c_cvCornerMinEigenVal = (<cvCornerMinEigenValPtr*><size_t>
                         ctypes.addressof(cv.cvCornerMinEigenVal))[0]

# cvCornerHarris
ctypedef void (*cvCornerHarrisPtr)(IplImage*, IplImage*, int, int, double)
cdef cvCornerHarrisPtr c_cvCornerHarris
c_cvCornerHarris = (<cvCornerHarrisPtr*><size_t>
                    ctypes.addressof(cv.cvCornerHarris))[0]

# cvFindCornerSubPix
ctypedef void (*cvFindCornerSubPixPtr)(IplImage*, CvPoint2D32f*, int,
                                       CvSize, CvSize, CvTermCriteria)
cdef cvFindCornerSubPixPtr c_cvFindCornerSubPix
c_cvFindCornerSubPix = (<cvFindCornerSubPixPtr*>
                        <size_t>ctypes.addressof(cv.cvFindCornerSubPix))[0]

# cvGoodFeaturesToTrack
ctypedef void (*cvGoodFeaturesToTrackPtr)(IplImage*, IplImage*, IplImage*,
                                          CvPoint2D32f*, int*, double, double,
                                          IplImage*, int, int, double)
cdef cvGoodFeaturesToTrackPtr c_cvGoodFeaturesToTrack
c_cvGoodFeaturesToTrack = (<cvGoodFeaturesToTrackPtr*><size_t>
                           ctypes.addressof(cv.cvGoodFeaturesToTrack))[0]

# cvGetRectSubPix
ctypedef void (*cvGetRectSubPixPtr)(IplImage*, IplImage*, CvPoint2D32f)
cdef cvGetRectSubPixPtr c_cvGetRectSubPix
c_cvGetRectSubPix = (<cvGetRectSubPixPtr*><size_t>
                     ctypes.addressof(cv.cvGetRectSubPix))[0]

# cvGetQuadrangleSubPix
ctypedef void (*cvGetQuadrangleSubPixPtr)(IplImage*, IplImage*, CvMat*)
cdef cvGetQuadrangleSubPixPtr c_cvGetQuadrangleSubPix
c_cvGetQuadrangleSubPix = (<cvGetQuadrangleSubPixPtr*><size_t>
                           ctypes.addressof(cv.cvGetQuadrangleSubPix))[0]

# cvResize
ctypedef void (*cvResizePtr)(IplImage*, IplImage*, int)
cdef cvResizePtr c_cvResize
c_cvResize = (<cvResizePtr*><size_t>ctypes.addressof(cv.cvResize))[0]

# cvWarpAffine
ctypedef void (*cvWarpAffinePtr)(IplImage*, IplImage*, CvMat*, int, CvScalar)
cdef cvWarpAffinePtr c_cvWarpAffine
c_cvWarpAffine = (<cvWarpAffinePtr*><size_t>
                  ctypes.addressof(cv.cvWarpAffine))[0]

# cvWarpPerspective
ctypedef void (*cvWarpPerspectivePtr)(IplImage*, IplImage*, CvMat*, int,
                                      CvScalar)
cdef cvWarpPerspectivePtr c_cvWarpPerspective
c_cvWarpPerspective = (<cvWarpPerspectivePtr*><size_t>
                       ctypes.addressof(cv.cvWarpPerspective))[0]

# cvLogPolar
ctypedef void (*cvLogPolarPtr)(IplImage*, IplImage*, CvPoint2D32f, double, int)
cdef cvLogPolarPtr c_cvLogPolar
c_cvLogPolar = (<cvLogPolarPtr*><size_t>ctypes.addressof(cv.cvLogPolar))[0]

# cvErode
ctypedef void (*cvErodePtr)(IplImage*, IplImage*, IplConvKernel*, int)
cdef cvErodePtr c_cvErode
c_cvErode = (<cvErodePtr*><size_t>ctypes.addressof(cv.cvErode))[0]

# cvDilate
ctypedef void (*cvDilatePtr)(IplImage*, IplImage*, IplConvKernel*, int)
cdef cvDilatePtr c_cvDilate
c_cvDilate = (<cvDilatePtr*><size_t>ctypes.addressof(cv.cvDilate))[0]

# cvMorphologyEx
ctypedef void (*cvMorphologyExPtr)(IplImage*, IplImage*, IplImage*,
                                   IplConvKernel*, int, int)
cdef cvMorphologyExPtr c_cvMorphologyEx
c_cvMorphologyEx = (<cvMorphologyExPtr*><size_t>
                        ctypes.addressof(cv.cvMorphologyEx))[0]

# cvSmooth
ctypedef void (*cvSmoothPtr)(IplImage*, IplImage*, int, int,
                             int, double, double)
cdef cvSmoothPtr c_cvSmooth
c_cvSmooth =  (<cvSmoothPtr*><size_t>ctypes.addressof(cv.cvSmooth))[0]

# cvFilter2D
ctypedef void (*cvFilter2DPtr)(IplImage*, IplImage*, CvMat*, CvPoint)
cdef cvFilter2DPtr c_cvFilter2D
c_cvFilter2D = (<cvFilter2DPtr*><size_t>ctypes.addressof(cv.cvFilter2D))[0]

# cvIntegral
ctypedef void (*cvIntegralPtr)(IplImage*, IplImage*, IplImage*, IplImage*)
cdef cvIntegralPtr c_cvIntegral
c_cvIntegral = (<cvIntegralPtr*><size_t>ctypes.addressof(cv.cvIntegral))[0]

# cvCvtColor
ctypedef void (*cvCvtColorPtr)(IplImage*, IplImage*, int)
cdef cvCvtColorPtr c_cvCvtColor
c_cvCvtColor = (<cvCvtColorPtr*><size_t>ctypes.addressof(cv.cvCvtColor))[0]

# cvThreshold
ctypedef double (*cvThresholdPtr)(IplImage*, IplImage*, double, double, int)
cdef cvThresholdPtr c_cvThreshold
c_cvThreshold = (<cvThresholdPtr*><size_t>ctypes.addressof(cv.cvThreshold))[0]

# cvAdaptiveThreshold
ctypedef void (*cvAdaptiveThresholdPtr)(IplImage*, IplImage*, double, int, int,
                                        int, double)
cdef cvAdaptiveThresholdPtr c_cvAdaptiveThreshold
c_cvAdaptiveThreshold = (<cvAdaptiveThresholdPtr*><size_t>
                         ctypes.addressof(cv.cvAdaptiveThreshold))[0]

# cvPyrDown
ctypedef void (*cvPyrDownPtr)(IplImage*, IplImage*, int)
cdef cvPyrDownPtr c_cvPyrDown
c_cvPyrDown = (<cvPyrDownPtr*><size_t>ctypes.addressof(cv.cvPyrDown))[0]

# cvPyrUp
ctypedef void (*cvPyrUpPtr)(IplImage*, IplImage*, int)
cdef cvPyrUpPtr c_cvPyrUp
c_cvPyrUp = (<cvPyrUpPtr*><size_t>ctypes.addressof(cv.cvPyrUp))[0]

# cvWatershed
ctypedef void (*cvWatershedPtr)(IplImage*, IplImage*)
cdef cvWatershedPtr c_cvWatershed
c_cvWatershed = (<cvWatershedPtr*><size_t>ctypes.addressof(cv.cvWatershed))[0]

# cvCalibrateCamera2
ctypedef void (*cvCalibrateCamera2Ptr)(CvMat*, CvMat*, CvMat*,
       CvSize, CvMat*, CvMat*, CvMat*, CvMat*, int)
cdef cvCalibrateCamera2Ptr c_cvCalibrateCamera2
c_cvCalibrateCamera2 = (<cvCalibrateCamera2Ptr*>
                        <size_t>ctypes.addressof(cv.cvCalibrateCamera2))[0]

# cvUndistort2
ctypedef void (*cvUndistort2Ptr)(IplImage*, IplImage*, CvMat*, CvMat*, CvMat*)
cdef cvUndistort2Ptr c_cvUndistort2
c_cvUndistort2 = (<cvUndistort2Ptr*><size_t>ctypes.addressof(cv.cvUndistort2))[0]

# cvFindChessboardCorners
ctypedef void (*cvFindChessboardCornersPtr)(IplImage*, CvSize, CvPoint2D32f*,
                                            int*, int)
cdef cvFindChessboardCornersPtr c_cvFindChessboardCorners
c_cvFindChessboardCorners = (<cvFindChessboardCornersPtr*><size_t>
                             ctypes.addressof(cv.cvFindChessboardCorners))[0]

# cvFindExtrinsicCameraParams2
ctypedef void (*cvFindExtrinsicCameraParams2Ptr)(CvMat*, CvMat*, CvMat*, CvMat*,
                                                 CvMat*, CvMat*, int)
cdef cvFindExtrinsicCameraParams2Ptr c_cvFindExtrinsicCameraParams2
c_cvFindExtrinsicCameraParams2 = \
                        (<cvFindExtrinsicCameraParams2Ptr*><size_t>
                         ctypes.addressof(cv.cvFindExtrinsicCameraParams2))[0]

# cvFindFundamentalMat
ctypedef int (*cvFindFundamentalMatPtr)(CvMat*, CvMat*, CvMat*, int, double,
                                        double, CvMat*)
cdef cvFindFundamentalMatPtr c_cvFindFundamentalMat
c_cvFindFundamentalMat = \
                       (<cvFindFundamentalMatPtr*><size_t>
                        ctypes.addressof(cv.cvFindFundamentalMat))[0]

# cvDrawChessboardCorners
ctypedef void (*cvDrawChessboardCornersPtr)(IplImage*, CvSize, CvPoint2D32f*,
                                            int, int)
cdef cvDrawChessboardCornersPtr c_cvDrawChessboardCorners
c_cvDrawChessboardCorners = (<cvDrawChessboardCornersPtr*><size_t>
                             ctypes.addressof(cv.cvDrawChessboardCorners))[0]

# cvFloodFill
ctypedef void (*cvFloodFillPtr)(IplImage*, CvPoint, CvScalar, CvScalar,
                                CvScalar, void*, int, IplImage*)
cdef cvFloodFillPtr c_cvFloodFill
c_cvFloodFill = (<cvFloodFillPtr*><size_t>ctypes.addressof(cv.cvFloodFill))[0]

# cvMatchTemplate
ctypedef void (*cvMatchTemplatePtr)(IplImage*, IplImage*, IplImage*, int)
cdef cvMatchTemplatePtr c_cvMatchTemplate
c_cvMatchTemplate = (<cvMatchTemplatePtr*><size_t>
                     ctypes.addressof(cv.cvMatchTemplate))[0]

#-------------------------------------------------------------------------------
# Function Implementations
#-------------------------------------------------------------------------------

#--------
# cvSobel
#--------

@cvdoc(package='cv', group='filter', doc=\
'''cvSobel(src, xorder=1, yorder=0, aperture_size=3)

Apply the Sobel operator to the input image.

Parameters
----------
src : ndarray, 2D, dtype=[uint8, int8, float32]
    The source image.
xorder : integer
    The x order of the Sobel operator.
yorder : integer
    The y order of the Sobel operator.
aperture_size : integer=[3, 5, 7]
    The size of the Sobel kernel.

Returns
-------
out : ndarray
    A new which is the result of applying the Sobel
    operator to src.''')
def cvSobel(np.ndarray src, int xorder=1, int yorder=0,
            int aperture_size=3):

    validate_array(src)
    assert_dtype(src, [UINT8, INT8, FLOAT32])
    assert_nchannels(src, [1])

    if (aperture_size != 3 and aperture_size != 5 and aperture_size != 7):
        raise ValueError('aperture_size must be 3, 5, or 7')

    cdef np.ndarray out

    if src.dtype == UINT8 or src.dtype == INT8:
        out = new_array_like_diff_dtype(src, INT16)
    else:
        out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg

    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvSobel(&srcimg, &outimg, xorder, yorder, aperture_size)

    return out


#----------
# cvLaplace
#----------

@cvdoc(package='cv', group='filter', doc=\
'''cvLaplace(src, aperture_size=3)

Apply the Laplace operator to the input image.

Parameters
----------
src : ndarray, 2D, dtype=[uint8, int8, float32]
    The source image.
aperture_size : integer=[3, 5, 7]
    The size of the Sobel kernel.

Returns
-------
out : ndarray
    A new which is the result of applying the Laplace
    operator to src.''')
def cvLaplace(np.ndarray src, int aperture_size=3):

    validate_array(src)
    assert_dtype(src, [UINT8, INT8, FLOAT32])
    assert_nchannels(src, [1])

    if (aperture_size != 3 and aperture_size != 5 and aperture_size != 7):
        raise ValueError('aperture_size must be 3, 5, or 7')

    cdef np.ndarray out

    if src.dtype == UINT8 or src.dtype == INT8:
        out = new_array_like_diff_dtype(src, INT16)
    else:
        out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg

    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvLaplace(&srcimg, &outimg, aperture_size)

    return out


#--------
# cvCanny
#--------

@cvdoc(package='cv', group='feature', doc=\
'''cvCanny(src, threshold1=10, threshold2=50, aperture_size=3)

Apply Canny edge detection to the input image.

Parameters
----------
src : ndarray, 2D, dtype=[uint8]
    The source image.
threshold1 : float
    The lower threshold used for edge linking.
threshold2 : float
    The upper threshold used to find strong edges.
aperture_size : integer=[3, 5, 7]
    The size of the Sobel kernel.

Returns
-------
out : ndarray
    A new which is the result of applying Canny
    edge detection to src.''')
def cvCanny(np.ndarray src, double threshold1=10, double threshold2=50,
            int aperture_size=3):

    validate_array(src)
    assert_dtype(src, [UINT8])
    assert_nchannels(src, [1])

    if (aperture_size != 3 and aperture_size != 5 and aperture_size != 7):
        raise ValueError('aperture_size must be 3, 5, or 7')

    cdef np.ndarray out
    out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvCanny(&srcimg, &outimg, threshold1, threshold2, aperture_size)

    return out


#------------------
# cvPreCornerDetect
#------------------

@cvdoc(package='cv', group='feature', doc=\
'''cvPreCornerDetect(src, aperture_size=3)

Calculate the feature map for corner detection.

Parameters
----------
src : ndarray, 2D, dtype=[uint8, float32]
    The source image.
aperture_size : integer=[3, 5, 7]
    The size of the Sobel kernel.

Returns
-------
out : ndarray
    A new array of the corner candidates.''')
def cvPreCornerDetect(np.ndarray src, int aperture_size=3):

    validate_array(src)
    assert_dtype(src, [UINT8, FLOAT32])
    assert_nchannels(src, [1])

    if (aperture_size != 3 and aperture_size != 5 and aperture_size != 7):
        raise ValueError('aperture_size must be 3, 5, or 7')

    cdef np.ndarray out
    out = new_array_like_diff_dtype(src, FLOAT32)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvPreCornerDetect(&srcimg, &outimg, aperture_size)

    return out


#-------------------------
# cvCornerEigenValsAndVecs
#-------------------------

@cvdoc(package='cv', group='feature', doc=\
'''cvCornerEigenValsAndVecs(src, block_size=3, aperture_size=3)

Calculates the eigenvalues and eigenvectors of image
blocks for corner detection.

Parameters
----------
src : ndarray, 2D, dtype=[uint8, float32]
    The source image.
block_size : integer
    The size of the neighborhood in which to calculate
    the eigenvalues and eigenvectors.
aperture_size : integer=[3, 5, 7]
    The size of the Sobel kernel.

Returns
-------
out : ndarray
    A new array of the eigenvalues and eigenvectors.
    The shape of this array is (height, width, 6),
    Where height and width are the same as that
    of src.''')
def cvCornerEigenValsAndVecs(np.ndarray src, int block_size=3,
                                             int aperture_size=3):

    validate_array(src)
    assert_nchannels(src, [1])
    assert_dtype(src, [UINT8, FLOAT32])

    if (aperture_size != 3 and aperture_size != 5 and aperture_size != 7):
        raise ValueError('aperture_size must be 3, 5, or 7')

    cdef np.ndarray out
    cdef np.npy_intp outshape[2]
    outshape[0] = src.shape[0]
    outshape[1] = src.shape[1] * 6

    out = new_array(2, outshape, FLOAT32)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvCornerEigenValsAndVecs(&srcimg, &outimg, block_size, aperture_size)

    return out.reshape(out.shape[0], -1, 6)


#--------------------
# cvCornerMinEigenVal
#--------------------

@cvdoc(package='cv', group='feature', doc=\
'''cvCornerMinEigenVal(src, block_size=3, aperture_size=3)

Calculates the minimum eigenvalues of gradient matrices
for corner detection.

Parameters
----------
src : ndarray, 2D, dtype=[uint8, float32]
    The source image.
block_size : integer
    The size of the neighborhood in which to calculate
    the eigenvalues.
aperture_size : integer=[3, 5, 7]
    The size of the Sobel kernel.

Returns
-------
out : ndarray
    A new array of the eigenvalues.''')
def cvCornerMinEigenVal(np.ndarray src, int block_size=3,
                                        int aperture_size=3):

    validate_array(src)
    assert_nchannels(src, [1])
    assert_dtype(src, [UINT8, FLOAT32])

    if (aperture_size != 3 and aperture_size != 5 and aperture_size != 7):
        raise ValueError('aperture_size must be 3, 5, or 7')

    cdef np.ndarray out
    out = new_array_like_diff_dtype(src, FLOAT32)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvCornerMinEigenVal(&srcimg, &outimg, block_size, aperture_size)

    return out


#---------------
# cvCornerHarris
#---------------

@cvdoc(package='cv', group='feature', doc=\
'''cvCornerHarris(src, block_size=3, aperture_size=3, k=0.04)

Applies the Harris edge detector to the input image.

Parameters
----------
src : ndarray, 2D, dtype=[uint8, float32]
    The source image.
block_size : integer
    The size of the neighborhood in which to apply the detector.
aperture_size : integer=[3, 5, 7]
    The size of the Sobel kernel.
k : float
    Harris detector free parameter. See Notes.

Returns
-------
out : ndarray
    A new array of the Harris corners.

Notes
-----
The function cvCornerHarris() runs the Harris edge
detector on the image. Similarly to cvCornerMinEigenVal()
and cvCornerEigenValsAndVecs(), for each pixel it calculates
a gradient covariation matrix M over a block_size X block_size
neighborhood. Then, it stores det(M) - k * trace(M)**2
to the output image. Corners in the image can be found as the
local maxima of the output image.''')
def cvCornerHarris(np.ndarray src, int block_size=3, int aperture_size=3,
                                                     double k=0.04):

    validate_array(src)
    assert_nchannels(src, [1])
    assert_dtype(src, [UINT8, FLOAT32])

    if (aperture_size != 3 and aperture_size != 5 and aperture_size != 7):
        raise ValueError('aperture_size must be 3, 5, or 7')

    cdef np.ndarray out
    out = new_array_like_diff_dtype(src, FLOAT32)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvCornerHarris(&srcimg, &outimg, block_size, aperture_size, k)

    return out


#-------------------
# cvFindCornerSubPix
#-------------------

@cvdoc(package='cv', group='feature', doc=\
'''cvFindCornerSubPix(src, corners, win, zero_zone=(-1, -1), iterations=0, epsilon=1e-5)

Refines corner locations to sub-pixel accuracy.

Parameters
----------
src : ndarray, 2D, dtype=[uint8]
    The source image.
corners : ndarray, shape=(N x 2)
    An initial approximation of the corners in the image.
    The corners will be refined in-place in this array.
win : tuple, (height, width)
    The window within which the function iterates until it
    converges on the real corner. The actual window is twice
    the size of what is declared here. (an OpenCV peculiarity).
zero_zone : Half of the size of the dead region in the middle
    of the search zone over which the calculations are not
    performed. It is used sometimes to avoid possible
    singularities of the autocorrelation matrix.
    The value of (-1,-1) indicates that there is no such size.
iterations : integer
    The maximum number of iterations to perform. If 0,
    the function iterates until the error is less than epsilon.
epsilon : float
    The epsilon error, below which the function terminates.
    Can be used in combination with iterations.

Returns
-------
None. The array 'corners' is modified in place.''')
def cvFindCornerSubPix(np.ndarray src, np.ndarray corners, win,
                       zero_zone=(-1, -1), int iterations=0,
                       double epsilon=1e-5):

    validate_array(src)
    assert_nchannels(src, [1])
    assert_dtype(src, [UINT8])

    validate_array(corners)
    assert_ndims(corners, [2])
    assert_dtype(corners, [FLOAT32])

    cdef int count = <int>(corners.shape[0] * corners.shape[1] / 2.)
    cdef CvPoint2D32f* cvcorners = array_as_cvPoint2D32f_ptr(corners)

    if len(win) != 2:
        raise ValueError('win must be a 2-tuple')
    cdef CvSize cvwin
    cvwin.height = <int> win[0]
    cvwin.width = <int> win[1]

    cdef int imgheight = src.shape[0]
    cdef int imgwidth = src.shape[1]
    if imgwidth < (cvwin.width * 2 + 5) or imgheight  < (cvwin.height * 2 + 5):
        raise ValueError('The window is too large.')

    cdef CvSize cvzerozone
    cvzerozone.height = <int> zero_zone[0]
    cvzerozone.width = <int> zero_zone[1]

    cdef IplImage srcimg
    populate_iplimage(src, &srcimg)

    cdef CvTermCriteria crit
    crit = get_cvTermCriteria(iterations, epsilon)

    c_cvFindCornerSubPix(&srcimg, cvcorners, count, cvwin, cvzerozone, crit)

    return None


#----------------------
# cvGoodFeaturesToTrack
#----------------------

@cvdoc(package='cv', group='feature', doc=\
'''cvGoodFeaturesToTrack(src, corner_count, quality_level, min_distance, block_size=3, use_harris=0, k=0.04)

Determines strong corners in an image.

Parameters
----------
src : ndarray, 2D, dtype=[uint8, float32]
    The source image.
corner_count : int
    The maximum number of corners to find.
    Only found corners are returned.
quality_level : float
    Multiplier for the max/min eigenvalue;
    specifies the minimal accepted quality of
    image corners.
min_distance : float
    Limit, specifying the minimum possible
    distance between the returned corners;
    Euclidian distance is used.
block_size : integer
    The size of the neighborhood in which to apply the detector.
use_harris : integer
    If nonzero, Harris operator (cvCornerHarris())
    is used instead of default cvCornerMinEigenVal()
k : float
    Harris detector free parameter.
    Used only if use_harris != 0.

Returns
-------
out : ndarray
    The locations of the found corners in the image.

Notes
-----
This function finds distinct and strong corners
in an image which can be used as features in a tracking
algorithm. It also insures that features are distanced
from one another by at least min_distance.''')
def cvGoodFeaturesToTrack(np.ndarray src, int corner_count,
                          double quality_level, double min_distance,
                          int block_size=3, int use_harris=0, double k=0.04):

    validate_array(src)
    assert_dtype(src, [UINT8, FLOAT32])
    assert_nchannels(src, [1])

    cdef np.ndarray eig = new_array_like_diff_dtype(src, FLOAT32)
    cdef np.ndarray temp = new_array_like(eig)

    cdef np.npy_intp cornershape[2]
    cornershape[0] = <np.npy_intp>corner_count
    cornershape[1] = 2

    cdef np.ndarray out = new_array(2, cornershape, FLOAT32)
    cdef CvPoint2D32f* cvcorners = array_as_cvPoint2D32f_ptr(out)

    cdef int ncorners_found
    ncorners_found = corner_count

    cdef IplImage srcimg
    cdef IplImage eigimg
    cdef IplImage tempimg
    cdef IplImage *maskimg

    populate_iplimage(src, &srcimg)
    populate_iplimage(eig, &eigimg)
    populate_iplimage(temp, &tempimg)

    # don't need to support ROI. The user can just pass a slice.
    maskimg = NULL

    c_cvGoodFeaturesToTrack(&srcimg, &eigimg, &tempimg, cvcorners,
                            &ncorners_found, quality_level, min_distance,
                            maskimg, block_size,
                            use_harris, k)

    return out[:ncorners_found]


#----------------
# cvGetRectSubPix
#----------------

@cvdoc(package='cv', group='geometry', doc=\
'''cvGetRectSubPix(src, size, center)

Retrieves the pixel rectangle from an image with
sub-pixel accuracy.

Parameters
----------
src : ndarray
    The source image.
size : two tuple, integers, (height, width)
    The size of the rectangle to extract.
center : two tuple, floats, (x, y)
    The center location of the rectangle.
    The center must lie within the image, but the
    rectangle may extend beyond the bounds of the image.

Returns
-------
out : ndarray
    The extracted rectangle of the image.

Notes
-----
The center of the specified rectangle must
lie within the image, but the bounds of the rectangle
may extend beyond the image. Border replication is used
to fill in missing pixels.''')
def cvGetRectSubPix(np.ndarray src, size, center):

    validate_array(src)

    cdef np.npy_intp* shape = clone_array_shape(src)
    shape[0] = <np.npy_intp>size[0]
    shape[1] = <np.npy_intp>size[1]

    cdef CvPoint2D32f cvcenter
    cvcenter.x = <float>center[0]
    cvcenter.y = <float>center[1]

    cdef np.ndarray out = new_array(src.ndim, shape, src.dtype)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvGetRectSubPix(&srcimg, &outimg, cvcenter)

    PyMem_Free(shape)

    return out


#----------------------
# cvGetQuadrangleSubPix
#----------------------

@cvdoc(package='cv', group='geometry', doc=\
'''cvGetQuadrangleSubPix(src, warpmat, float_out=False)

Retrieves the pixel quandrangle from an image with
sub-pixel accuracy. In english: apply an affine transform to an image.

Parameters
----------
src : ndarray
    The source image.
warpmat : ndarray, 2x3
    The affine transformation to apply to the src image.
float_out : bool
    If True, the return array will have dtype np.float32.
    Otherwise, the return array will have the same dtype
    as the src array.
    If True, the src array MUST have dtype np.uint8

Returns
-------
out : ndarray
    Warped image of same size as src.

Notes
-----
The values of pixels at non-integer coordinates are retrieved
using bilinear interpolation. When the function needs pixels
outside of the image, it uses replication border mode to
reconstruct the values. Every channel of multiple-channel
images is processed independently.

This function has less overhead than cvWarpAffine
and should be used unless specific feature of that
function are required.''')
def cvGetQuadrangleSubPix(np.ndarray src, np.ndarray warpmat, float_out=False):

    validate_array(src)
    validate_array(warpmat)

    assert_nchannels(src, [1, 3])

    assert_nchannels(warpmat, [1])

    if warpmat.shape[0] != 2 or warpmat.shape[1] != 3:
        raise ValueError('warpmat must be 2x3')

    cdef np.ndarray out

    if float_out:
        assert_dtype(src, [UINT8])
        out = new_array_like_diff_dtype(src, FLOAT32)
    else:
        out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg
    cdef IplImage cvmat
    cdef CvMat* cvmatptr

    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)
    populate_iplimage(warpmat, &cvmat)
    cvmatptr = cvmat_ptr_from_iplimage(&cvmat)

    c_cvGetQuadrangleSubPix(&srcimg, &outimg, cvmatptr)

    PyMem_Free(cvmatptr)

    return out


#---------
# cvResize
#---------

@cvdoc(package='cv', group='geometry', doc=\
'''cvResize(src, size, method=CV_INTER_LINEAR)

Resize an to the given size.

Parameters
----------
src : ndarray
    The source image.
size : tuple, (height, width)
    The target resize size.
method : integer
    The interpolation method used for resizing.
    Supported methods are:
    CV_INTER_NN
    CV_INTER_LINEAR
    CV_INTER_AREA
    CV_INTER_CUBIC

Returns
-------
out : ndarray
    The resized image.''')
def cvResize(np.ndarray src, size, int method=CV_INTER_LINEAR):

    validate_array(src)

    if len(size) != 2:
        raise ValueError('size must be a 2-tuple (height, width)')

    if method not in [CV_INTER_NN, CV_INTER_LINEAR, CV_INTER_AREA,
                      CV_INTER_CUBIC]:
        raise ValueError('unsupported interpolation type')

    cdef int ndim = src.ndim
    cdef np.npy_intp* shape = clone_array_shape(src)
    shape[0] = <np.npy_intp>size[0]
    shape[1] = <np.npy_intp>size[1]

    cdef np.ndarray out = new_array(ndim, shape, src.dtype)
    validate_array(out)

    PyMem_Free(shape)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvResize(&srcimg, &outimg, method)

    return out


#-------------
# cvWarpAffine
#-------------

@cvdoc(package='cv', group='geometry', doc=\
'''cvWarpAffine(src, warpmat, flag=CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS, fillval=(0., 0., 0., 0.))

Applies an affine transformation to the image.

Parameters
----------
src : ndarray
    The source image.
warpmat : ndarray, 2x3
    The affine transformation to apply to the src image.
flag : integer
    A combination of interpolation and method flags.
    Supported flags are: (see notes)
    Interpolation:
        CV_INTER_NN
        CV_INTER_LINEAR
        CV_INTER_AREA
        CV_INTER_CUBIC
    Method:
        CV_WARP_FILL_OUTLIERS
        CV_WARP_INVERSE_MAP
fillval : 4-tuple, (R, G, B, A)
    The color to fill in missing pixels. Defaults to black.
    For < 4 channel images, use 0.'s for the value.

Returns
-------
out : ndarray
    The warped image of same size and dtype as src.

Notes
-----
CV_WARP_FILL_OUTLIERS - fills all of the destination image pixels;
    if some of them correspond to outliers in the source image,
    they are set to fillval.
CV_WARP_INVERSE_MAP - indicates that warpmat is inversely transformed
    from the destination image to the source and, thus, can be used
    directly for pixel interpolation. Otherwise, the function finds
    the inverse transform from warpmat.

This function has a larger overhead than cvGetQuadrangleSubPix,
and that function should be used instead, unless specific
features of this function are needed.''')
def cvWarpAffine(np.ndarray src, np.ndarray warpmat,
                 int flag=CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS,
                 fillval=(0., 0., 0., 0.)):

    validate_array(src)
    validate_array(warpmat)
    if len(fillval) != 4:
        raise ValueError('fillval must be a 4-tuple')
    assert_nchannels(src, [1, 3])
    assert_nchannels(warpmat, [1])

    if warpmat.shape[0] != 2 or warpmat.shape[1] != 3:
        raise ValueError('warpmat must be 2x3')

    valid_flags = [0, 1, 2, 3, 8, 16, 9, 17, 11, 19, 10, 18]
    if flag not in valid_flags:
        raise ValueError('unsupported flag combination')

    cdef np.ndarray out
    out = new_array_like(src)

    cdef CvScalar cvfill
    cdef int i
    for i in range(4):
        cvfill.val[i] = <double>fillval[i]

    cdef IplImage srcimg
    cdef IplImage outimg
    cdef IplImage cvmat
    cdef CvMat* cvmatptr

    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)
    populate_iplimage(warpmat, &cvmat)
    cvmatptr = cvmat_ptr_from_iplimage(&cvmat)

    c_cvWarpAffine(&srcimg, &outimg, cvmatptr, flag, cvfill)

    PyMem_Free(cvmatptr)

    return out


#------------------
# cvWarpPerspective
#------------------

@cvdoc(package='cv', group='geometry', doc=\
'''cvWarpPerspective(src, warpmat, flag=CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS, fillval=(0., 0., 0., 0.))

Applies a perspective transformation to an image.

Parameters
----------
src : ndarray
    The source image.
warpmat : ndarray, 3x3
    The affine transformation to apply to the src image.
flag : integer
    A combination of interpolation and method flags.
    Supported flags are: (see notes)
    Interpolation:
        CV_INTER_NN
        CV_INTER_LINEAR
        CV_INTER_AREA
        CV_INTER_CUBIC
    Method:
        CV_WARP_FILL_OUTLIERS
        CV_WARP_INVERSE_MAP
fillval : 4-tuple, (R, G, B, A)
    The color to fill in missing pixels. Defaults to black.
    For < 4 channel images, use 0.'s for the value.

Returns
-------
out : ndarray
    The warped image of same size and dtype as src.

Notes
-----
CV_WARP_FILL_OUTLIERS - fills all of the destination image pixels;
    if some of them correspond to outliers in the source image,
    they are set to fillval.
CV_WARP_INVERSE_MAP - indicates that warpmat is inversely transformed
    from the destination image to the source and, thus, can be used
    directly for pixel interpolation. Otherwise, the function finds
    the inverse transform from warpmat.''')
def cvWarpPerspective(np.ndarray src, np.ndarray warpmat,
                      int flag=CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS,
                      fillval=(0., 0., 0., 0.)):

    validate_array(src)
    validate_array(warpmat)
    if len(fillval) != 4:
        raise ValueError('fillval must be a 4-tuple')
    assert_nchannels(src, [1, 3])
    assert_nchannels(warpmat, [1])
    if warpmat.shape[0] != 3 or warpmat.shape[1] != 3:
        raise ValueError('warpmat must be 3x3')

    valid_flags = [0, 1, 2, 3, 8, 16, 9, 17, 11, 19, 10, 18]
    if flag not in valid_flags:
        raise ValueError('unsupported flag combination')

    cdef np.ndarray out
    out = new_array_like(src)

    cdef CvScalar cvfill
    cdef int i
    for i in range(4):
        cvfill.val[i] = <double>fillval[i]

    cdef IplImage srcimg
    cdef IplImage outimg
    cdef IplImage cvmat
    cdef CvMat* cvmatptr = NULL

    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)
    populate_iplimage(warpmat, &cvmat)
    cvmatptr = cvmat_ptr_from_iplimage(&cvmat)
    c_cvWarpPerspective(&srcimg, &outimg, cvmatptr, flag, cvfill)

    PyMem_Free(cvmatptr)

    return out


#-----------
# cvLogPolar
#-----------

@cvdoc(package='cv', group='geometry', doc=\
'''cvLogPolar(src, center, M, flag=CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS)

Remaps and image to Log-Polar space.

Parameters
----------
src : ndarray
    The source image.
center : tuple, (x, y)
    The keypoint for the log polar transform.
M : float
    The scale factor for the transform.
    (40 is a good starting point for a 256x256 image)
flag : integer
    A combination of interpolation and method flags.
    Supported flags are: (see notes)
    Interpolation:
        CV_INTER_NN
        CV_INTER_LINEAR
        CV_INTER_AREA
        CV_INTER_CUBIC
    Method:
        CV_WARP_FILL_OUTLIERS
        CV_WARP_INVERSE_MAP

Returns
-------
out : ndarray
    A transformed image the same size and dtype as src.

Notes
-----
CV_WARP_FILL_OUTLIERS - fills all of the destination image pixels;
    if some of them correspond to outliers in the source image,
    they are set to zero.
CV_WARP_INVERSE_MAP - assume that the source image is already
    in Log-Polar space, and transform back to cartesian space.

The function emulates the human “foveal” vision and can be used
for fast scale and rotation-invariant template matching,
for object tracking and so forth.''')
def cvLogPolar(np.ndarray src, center, double M,
               int flag=CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS):

    validate_array(src)
    if len(center) != 2:
        raise ValueError('center must be a 2-tuple')

    valid_flags = [0, 16, 8, 24, 1, 17, 9, 25, 2, 18, 10, 26, 3, 19, 11, 27]
    if flag not in valid_flags:
        raise ValueError('unsupported flag combination')

    cdef np.ndarray out = new_array_like(src)

    cdef CvPoint2D32f cv_center
    cv_center.x = <float>center[0]
    cv_center.y = <float>center[1]

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvLogPolar(&srcimg, &outimg, cv_center, M, flag)
    return out


#--------
# cvErode
#--------

@cvdoc(package='cv', group='filter', doc=\
'''cvErode(src, element=None, iterations=1, anchor=None, in_place=False)

Erode the source image with the given element.

Parameters
----------
src : ndarray
    The source image.
element : ndarray, 2D
    The structuring element. Must be 2D. Non-zero elements
    indicate which pixels of the underlying image to include
    in the operation as the element is slid over the image.
    If None, a 3x3 block element is used.
iterations : integer
    The number of times to perform the operation.
anchor: 2-tuple, (x, y)
    The anchor of the structuring element. Must be
    FULLY inside the element. If None, the center of the
    element is used.
in_place: bool
    If True, perform the operation in place.
    Otherwise, store the results in a new image.

Returns
-------
out/None : ndarray or None
    An new array is returned only if in_place=False.
    Otherwise, this function returns None.''')
def cvErode(np.ndarray src, np.ndarray element=None, int iterations=1,
            anchor=None, in_place=False):

    validate_array(src)

    cdef np.ndarray out
    cdef IplConvKernel* iplkernel

    if element == None:
        iplkernel = NULL
    else:
        iplkernel = get_IplConvKernel_ptr_from_array(element, anchor)

    if in_place:
        out = src
    else:
        out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvErode(&srcimg, &outimg, iplkernel, iterations)

    free_IplConvKernel(iplkernel)

    if in_place:
        return None
    else:
        return out


#---------
# cvDilate
#---------

@cvdoc(package='cv', group='filter', doc=\
'''cvDilate(src, element=None, iterations=1, anchor=None, in_place=False)

Dilate the source image with the given element.

Parameters
----------
src : ndarray
    The source image.
element : ndarray, 2D
    The structuring element. Must be 2D. Non-zero elements
    indicate which pixels of the underlying image to include
    in the operation as the element is slid over the image.
    If None, a 3x3 block element is used.
iterations : integer
    The number of times to perform the operation.
anchor: 2-tuple, (x, y)
    The anchor of the structuring element. Must be
    FULLY inside the element. If None, the center of the
    element is used.
in_place: bool
    If True, perform the operation in place.
    Otherwise, store the results in a new image.

Returns
-------
out/None : ndarray or None
    An new array is returned only if in_place=False.
    Otherwise, this function returns None.''')
def cvDilate(np.ndarray src, np.ndarray element=None, int iterations=1,
            anchor=None, in_place=False):

    validate_array(src)

    cdef np.ndarray out
    cdef IplConvKernel* iplkernel

    if element == None:
        iplkernel = NULL
    else:
        iplkernel = get_IplConvKernel_ptr_from_array(element, anchor)

    if in_place:
        out = src
    else:
        out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvDilate(&srcimg, &outimg, iplkernel, iterations)

    free_IplConvKernel(iplkernel)

    if in_place:
        return None
    else:
        return out


#---------------
# cvMorphologyEx
#---------------

@cvdoc(package='cv', group='filter', doc=\
'''cvMorphologyEx(src, element, operation, iterations=1, anchor=None, in_place=False)

Apply a morphological operation to the image.

Parameters
----------
src : ndarray
    The source image.
element : ndarray, 2D
    The structuring element. Must be 2D. Non-zero elements
    indicate which pixels of the underlying image to include
    in the operation as the element is slid over the image.
    Cannot be None.
operation : flag
    The morphology operation to perform. Must be one of:
    CV_MOP_OPEN
    CV_MOP_CLOSE
    CV_MOP_GRADIENT
    CV_MOP_TOPHAT
    CV_MOP_BLACKHAT
iterations : integer
    The number of times to perform the operation.
anchor: 2-tuple, (x, y)
    The anchor of the structuring element. Must be
    FULLY inside the element. If None, the center of the
    element is used.
in_place: bool
    If True, perform the operation in place.
    Otherwise, store the results in a new image.

Returns
-------
out/None : ndarray or None
    An new array is returned only if in_place=False.
    Otherwise, this function returns None.''')
def cvMorphologyEx(np.ndarray src, np.ndarray element, int operation,
                   int iterations=1, anchor=None, in_place=False):

    validate_array(src)

    cdef np.ndarray out
    cdef np.ndarray temp
    cdef IplConvKernel* iplkernel

    iplkernel = get_IplConvKernel_ptr_from_array(element, anchor)

    if in_place:
        out = src
    else:
        out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg
    cdef IplImage tempimg
    cdef IplImage* tempimgptr = &tempimg

    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    # determine if we need the tempimg
    if operation == CV_MOP_OPEN or operation == CV_MOP_CLOSE:
        tempimgptr = NULL
    elif operation == CV_MOP_GRADIENT:
        temp = new_array_like(src)
        populate_iplimage(temp, &tempimg)
    elif operation == CV_MOP_TOPHAT or operation == CV_MOP_BLACKHAT:
        if in_place:
            temp = new_array_like(src)
            populate_iplimage(temp, &tempimg)
        else:
            tempimgptr = NULL
    else:
        raise RuntimeError('operation type not understood')

    c_cvMorphologyEx(&srcimg, &outimg, tempimgptr, iplkernel, operation,
                     iterations)

    free_IplConvKernel(iplkernel)

    if in_place:
        return None
    else:
        return out


#---------
# cvSmooth
#---------

@cvdoc(package='cv', group='filter', doc=\
'''cvSmooth(src, smoothtype=CV_GAUSSIAN, param1=3, param2=0, param3=0., param4=0., in_place=False)

Smooth an image with the specified filter.

Parameters
----------
src : ndarray
    The source image.
smoothtype : integer
    The flag representing which smoothing operation to perfom.
    See notes on restrictions.
    Must be one of:
    CV_BLUR_NO_SCALE
    CV_BLUR
    CV_GAUSSIAN
    CV_MEDIAN
    CV_BILATERAL
param1 : integer
    See notes.
param2 : integer
    See notes.
param3 : float
    See notes.
param4 : float
    See notes.
in_place : bool
    If True, perform the operation in place.
    This is not supported for every combination of arguments.
    See notes.

Returns
-------
out/None : ndarray or None
    If in_place == True the function operates in place and returns None.
    Otherwise, the operation returns a new array that is
    the result of the smoothing operation.

Notes
-----
The following details the restrictions and argument interpretaions
for each of the smoothing operations.

CV_BLUR_NO_SCALE:
    Source image must be 2D and have dtype uint8, int8, or float32.
    param1 x param2 define the neighborhood over which the pixels
    are summed. If param2 is zero it is set equal to param1.
    param3 and param4 are ignored.
    in_place operation is not supported.
CV_BLUR:
    Source image must have dtype uint8, int8, or float32.
    param1 x param2 define the neighborhood over which the pixels
    are summed. If param2 is zero it is set equal to param1.
    param3 and param4 are ignored.
CV_GAUSSIAN:
    Source image must have dtype uint8, int8, or float32.
    param1 x param2 defines the size of the gaussian kernel.
    If param2 is zero it is set equal to param1.
    param3 is the standard deviation of the kernel.
    If param3 is zero, an optimum stddev is calculated based
    on the kernel size. If both param1 and param2 or zero,
    then an optimum kernel size is calculated based on
    param3.
    in_place operation is supported.
CV_MEDIAN:
    Source image must have dtype uint8, or int8.
    param1 x param1 define the neigborhood over which
    to find the median.
    param2, param3, and param4 are ignored.
    in_place operation is not supported.
CV_BILATERAL:
    Source image must have dtype uint8, or int8.
    param1 x param2 define the neighborhood.
    param3 defines the color stddev.
    param4 defines the space stddev.
    in_place operation is not supported.

Using standard sigma for small kernels (3x3 to 7x7)
gives better speed.''')
def cvSmooth(np.ndarray src, int smoothtype=CV_GAUSSIAN, int param1=3,
             int param2=0, double param3=0, double param4=0,
             bint in_place=False):

    validate_array(src)

    cdef np.ndarray out
    # there are restrictions that must be placed on the data depending on
    # the smoothing operation requested

    # CV_BLUR_NO_SCALE
    if smoothtype == CV_BLUR_NO_SCALE:

        if in_place:
            raise RuntimeError('In place operation not supported with this '
                               'filter')

        assert_dtype(src, [UINT8, INT8, FLOAT32])
        assert_ndims(src, [2])

        if src.dtype == FLOAT32:
            out = new_array_like(src)
        else:
            out = new_array_like_diff_dtype(src, INT16)

    # CV_BLUR and CV_GAUSSIAN
    elif smoothtype == CV_BLUR or smoothtype == CV_GAUSSIAN:

        assert_dtype(src, [UINT8, INT8, FLOAT32])
        assert_nchannels(src, [1, 3])

        if in_place:
            out = src
        else:
            out = new_array_like(src)

    # CV_MEDIAN and CV_BILATERAL
    else:
        assert_dtype(src, [UINT8, INT8])
        assert_nchannels(src, [1, 3])

        if in_place:
            raise RuntimeError('In place operation not supported with this '
                               'filter')

        out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvSmooth(&srcimg, &outimg, smoothtype, param1, param2, param3, param4)

    if in_place:
        return None
    else:
        return out


#-----------
# cvFilter2D
#-----------

@cvdoc(package='cv', group='filter', doc=\
'''cvFilter2D(src, kernel, anchor=None, in_place=False)

Convolve an image with the given kernel.

Parameters
----------
src : ndarray
    The source image.
kernel : ndarray, 2D, dtype=float32
    The kernel with which to convolve the image.
anchor : 2-tuple, (x, y)
    The kernel anchor.
in_place : bool
    If True, perform the operation in_place.

Returns
-------
out/None : ndarray or None
    If in_place is True, returns None.
    Otherwise a new array is returned which is the result
    of the convolution.

Notes
-----
This is a high performance function. OpenCV automatically
determines, based on the size of the image and the kernel,
whether it will faster to do the convolution in the spatial
or the frequency domain, and behaves accordingly.''')
def cvFilter2D(np.ndarray src, np.ndarray kernel, anchor=None, in_place=False):

    validate_array(src)
    validate_array(kernel)

    assert_ndims(kernel, [2])
    assert_dtype(kernel, [FLOAT32])

    cdef CvPoint cv_anchor
    if anchor is not None:
        assert len(anchor) == 2, 'anchor must be (x, y) tuple'
        cv_anchor.x = <int>anchor[0]
        cv_anchor.y = <int>anchor[1]
        assert (cv_anchor.x < kernel.shape[1]) and (cv_anchor.x >= 0) \
            and (cv_anchor.y < kernel.shape[0]) and (cv_anchor.y >= 0), \
            'anchor point must be inside kernel'
    else:
        cv_anchor.x = <int>(kernel.shape[1] / 2.)
        cv_anchor.y = <int>(kernel.shape[0] / 2.)

    cdef np.ndarray out

    if in_place:
        out = src
    else:
        out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg
    cdef IplImage kernelimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)
    populate_iplimage(kernel, &kernelimg)

    cdef CvMat* cv_kernel
    cv_kernel = cvmat_ptr_from_iplimage(&kernelimg)

    c_cvFilter2D(&srcimg, &outimg, cv_kernel, cv_anchor)

    PyMem_Free(cv_kernel)

    if in_place:
        return None
    else:
        return out


#-----------
# cvIntegral
#-----------

@cvdoc(package='cv', group='transforms', doc=\
'''cvIntegral(src, square_sum=False, titled_sum=False)

Calculate the integral of an image.

Parameters
----------
src : ndarray, dtyp=[uint8, float32, float64]
    The source image.
square_sum : bool
    If True, also returns the square sum.
tilted_sum : bool
    If True, also returns the titled sum (45 degree tilt)

Returns
-------
[out1, out2, out3] : list of ndarray's
    Returns a list consisting at least of:
    out1: the integral image, and optionally:
    out2: the square sum image
    out3: the titled sum image,
    or any combination of these two.''')
def cvIntegral(np.ndarray src, square_sum=False, tilted_sum=False):

    validate_array(src)
    assert_dtype(src, [UINT8, FLOAT32, FLOAT64])

    out = []

    cdef np.ndarray outsum
    cdef np.ndarray outsqsum
    cdef np.ndarray outtiltsum

    cdef IplImage srcimg
    cdef IplImage outsumimg
    cdef IplImage outsqsumimg
    cdef IplImage outtiltsumimg
    cdef IplImage* outsqsumimgptr = &outsqsumimg
    cdef IplImage* outtiltsumimgptr = &outtiltsumimg

    populate_iplimage(src, &srcimg)

    # out arrays need to be (H + 1) x (W + 1)
    cdef np.npy_intp* out_shape = clone_array_shape(src)
    out_shape[0] = src.shape[0] + 1
    out_shape[1] = src.shape[1] + 1
    cdef int out_dims = src.ndim

    if src.dtype == UINT8:
        outsum = new_array(out_dims, out_shape, INT32)
    else:
        outsum = new_array(out_dims, out_shape, FLOAT64)

    populate_iplimage(outsum, &outsumimg)
    out.append(outsum)

    if square_sum:
        outsqsum = new_array(out_dims, out_shape, FLOAT64)
        populate_iplimage(outsqsum, &outsqsumimg)
        out.append(outsqsum)
    else:
        outsqsumimgptr = NULL

    if tilted_sum:
        outtiltsum = new_array(out_dims, out_shape, outsum.dtype)
        populate_iplimage(outtiltsum, &outtiltsumimg)
        out.append(outtiltsum)
    else:
        outtiltsumimgptr = NULL

    c_cvIntegral(&srcimg, &outsumimg, outsqsumimgptr, outtiltsumimgptr)

    PyMem_Free(out_shape)

    return out


#-----------
# cvCvtColor
#-----------

@cvdoc(package='cv', group='transforms', doc=\
'''cvCvtColor(src, code)

Convert an image to another color space.

Parameters
----------
src : ndarray, dtype=[uint8, uint16, float32]
    The source image.
code : integer
    A flag representing which color conversion to perform.
    Valid flags are the following:
    CV_BGR2BGRA,    CV_RGB2RGBA,    CV_BGRA2BGR,    CV_RGBA2RGB,
    CV_BGR2RGBA,    CV_RGB2BGRA,    CV_RGBA2BGR,    CV_BGRA2RGB,
    CV_BGR2RGB,     CV_RGB2BGR,     CV_BGRA2RGBA,   CV_RGBA2BGRA,
    CV_BGR2GRAY,    CV_RGB2GRAY,    CV_GRAY2BGR,    CV_GRAY2RGB,
    CV_GRAY2BGRA,   CV_GRAY2RGBA,   CV_BGRA2GRAY,   CV_RGBA2GRAY,
    CV_BGR2BGR565,  CV_RGB2BGR565,  CV_BGR5652BGR,  CV_BGR5652RGB,
    CV_BGRA2BGR565, CV_RGBA2BGR565, CV_BGR5652BGRA, CV_BGR5652RGBA,
    CV_GRAY2BGR565, CV_BGR5652GRAY, CV_BGR2BGR555,  CV_RGB2BGR555,
    CV_BGR5552BGR,  CV_BGR5552RGB,  CV_BGRA2BGR555, CV_RGBA2BGR555,
    CV_BGR5552BGRA, CV_BGR5552RGBA, CV_GRAY2BGR555, CV_BGR5552GRAY,
    CV_BGR2XYZ,     CV_RGB2XYZ,     CV_XYZ2BGR,     CV_XYZ2RGB,
    CV_BGR2YCrCb,   CV_RGB2YCrCb,   CV_YCrCb2BGR,   CV_YCrCb2RGB,
    CV_BGR2HSV,     CV_RGB2HSV,     CV_BGR2Lab,     CV_RGB2Lab,
    CV_BayerBG2BGR, CV_BayerGB2BGR, CV_BayerRG2BGR, CV_BayerGR2BGR,
    CV_BayerBG2RGB, CV_BayerGB2RGB, CV_BayerRG2RGB, CV_BayerGR2RGB,
    CV_BGR2Luv,     CV_RGB2Luv,     CV_BGR2HLS,     CV_RGB2HLS,
    CV_HSV2BGR,     CV_HSV2RGB,     CV_Lab2BGR,     CV_Lab2RGB,
    CV_Luv2BGR,     CV_Luv2RGB,     CV_HLS2BGR,     CV_HLS2RGB

Returns
-------
out : ndarray
    A new image in the requested color-space, with
    an appropriate dtype.

Notes
-----
Not all conversion types support all dtypes.
An exception will be raise if the dtype is not supported.
See the OpenCV documentation for more details
about the specific color conversions.''')
def cvCvtColor(np.ndarray src, int code):

    validate_array(src)
    assert_dtype(src, [UINT8, UINT16, FLOAT32])

    try:
        conversion_params = _cvtcolor_dict[code]
    except KeyError:
        print 'unknown conversion code'
        raise

    cdef int src_channels = <int>conversion_params[0]
    cdef int out_channels = <int>conversion_params[1]
    src_dtypes = conversion_params[2]

    assert_nchannels(src, [src_channels])
    assert_dtype(src, src_dtypes)

    cdef np.ndarray out

    # the out array can be 2, 3, or 4 channels so we need shapes that
    # can handle either
    cdef np.npy_intp out_shape2[2]
    cdef np.npy_intp out_shape3[3]
    out_shape2[0] = src.shape[0]
    out_shape2[1] = src.shape[1]
    out_shape3[0] = src.shape[0]
    out_shape3[1] = src.shape[1]

    if out_channels == 1:
        out = new_array(2, out_shape2, src.dtype)
    else:
        out_shape3[2] = <np.npy_intp>out_channels
        out = new_array(3, out_shape3, src.dtype)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvCvtColor(&srcimg, &outimg, code)

    return out


#------------
# cvThreshold
#------------

@cvdoc(package='cv', group='transforms', doc=\
'''cvThreshold(src, threshold, max_value=255, threshold_type=CV_THRESH_BINARY, use_otsu=False)

Threshold an image.

Parameters
----------
src : ndarray, 2D, dtype=[uint8, float32]
threshold : float
    The threshold value. (decision value)
max_value : float
    The maximum value.
threshold_type : integer
    The flag representing which type of thresholding to apply.
    Valid flags are:
    CV_THRESH_BINARY (max_value if src(x,y) > threshold else 0)
    CV_THRESH_BINARY_INV (0 if src(x,y) > threshold else max_value)
    CV_THRESH_TRUNC (threshold if src(x,y) > threshold else src(x,y))
    CV_THRESH_TOZERO (src(x,y) if src(x,y) > threshold else 0)
    CV_THRESH_TOZERO_INV (0 if src(x,y) > threshold else src(x,y))
use_otsu : bool
    If true, the optimum threshold is automatically computed
    and the passed in threshold value is ignored.
    Only implemented for uint8 source images.

Returns
-------
out/(out, threshold) : ndarray or (ndarray, float)
    If use_otsu is True, then the computed threshold value is
    returned in addition to the thresholded image. Otherwise
    just the thresholded image is returned.''')
def cvThreshold(np.ndarray src, double threshold, double max_value=255,
                int threshold_type=CV_THRESH_BINARY, use_otsu=False):

    validate_array(src)
    assert_nchannels(src, [1])
    assert_dtype(src, [UINT8, FLOAT32])

    if use_otsu:
        assert_dtype(src, [UINT8])
        threshold_type += 8

    cdef np.ndarray out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    threshold = c_cvThreshold(&srcimg, &outimg, threshold, max_value,
                              threshold_type)

    if use_otsu:
        return (out, threshold)
    else:
        return out


#--------------------
# cvAdaptiveThreshold
#--------------------

@cvdoc(package='cv', group='transforms', doc=\
'''cvAdaptiveThreshold(src, max_value, adaptive_method=CV_ADAPTIVE_THRESH_MEAN_C, threshold_type=CV_THRESH_BINARY, block_size=3, param1=5)

Apply an adaptive threshold to an image.

Parameters
----------
src : ndarray, 2D, dtype=uint8
max_value : float
    The maximum value.
adaptive_method : integer
    The flag representing the adaptive method.
    Valid flags are:
    CV_ADAPTIVE_THRESH_MEAN_C (uses mean of the neighborhood)
    CV_ADAPTIVE_THRESH_GAUSSIAN_C (uses gaussian of the neighborhood)
threshold_type : integer
    The flag representing which type of thresholding to apply.
    Valid flags are:
    CV_THRESH_BINARY (max_value if src(x,y) > threshold else 0)
    CV_THRESH_BINARY_INV (0 if src(x,y) > threshold else max_value)
block_size : integer
    Defines a block_size x block_size neighborhood
param1 : float
    The weight to be subtracted from the neighborhood computation.

Returns
-------
out : ndarray
    The thresholded image.''')
def cvAdaptiveThreshold(np.ndarray src, double max_value,
                        int adaptive_method=CV_ADAPTIVE_THRESH_MEAN_C,
                        int threshold_type=CV_THRESH_BINARY,
                        int block_size=3, double param1=5):

    validate_array(src)
    assert_nchannels(src, [1])
    assert_dtype(src, [UINT8])

    if (adaptive_method!=CV_ADAPTIVE_THRESH_MEAN_C and
        adaptive_method!=CV_ADAPTIVE_THRESH_GAUSSIAN_C):
        raise ValueError('Invalid adaptive method')

    if (threshold_type!=CV_THRESH_BINARY and
        threshold_type!=CV_THRESH_BINARY_INV):
        raise ValueError('Invalid threshold type')

    if (block_size % 2 != 1 or block_size <= 1):
        raise ValueError('block size must be and odd number and greater than 1')

    cdef np.ndarray out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvAdaptiveThreshold(&srcimg, &outimg, max_value, adaptive_method,
                          threshold_type, block_size, param1)

    return out


#----------
# cvPyrDown
#----------

@cvdoc(package='cv', group='filter', doc=\
'''cvPyrDown(src)

Downsample an image.

Parameters
----------
src : ndarray, dtype=[uint8, uint16, float32, float64]

Returns
-------
out : ndarray
    Downsampled image half the size of the original
    in each dimension.''')
def cvPyrDown(np.ndarray src):

    validate_array(src)
    assert_dtype(src, [UINT8, UINT16, FLOAT32, FLOAT64])

    cdef int outdim = src.ndim
    cdef np.npy_intp* outshape = clone_array_shape(src)
    outshape[0] = <np.npy_intp>(src.shape[0] + 1) / 2
    outshape[1] = <np.npy_intp>(src.shape[1] + 1) / 2

    cdef np.ndarray out = new_array(outdim, outshape, src.dtype)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvPyrDown(&srcimg, &outimg, 7)

    PyMem_Free(outshape)

    return out


#--------
# cvPyrUp
#--------

@cvdoc(package='cv', group='filter', doc=\
'''cvPyrUp(src)

Upsample an image.

Parameters
----------
src : ndarray, dtype=[uint8, uint16, float32, float64]

Returns
-------
out : ndarray
    Upsampled image twice the size of the original
    in each dimension.''')
def cvPyrUp(np.ndarray src):

    validate_array(src)
    assert_dtype(src, [UINT8, UINT16, FLOAT32, FLOAT64])

    cdef int outdim = src.ndim
    cdef np.npy_intp* outshape = clone_array_shape(src)
    outshape[0] = <np.npy_intp>(src.shape[0] * 2)
    outshape[1] = <np.npy_intp>(src.shape[1] * 2)

    cdef np.ndarray out = new_array(outdim, outshape, src.dtype)

    cdef IplImage srcimg
    cdef IplImage outimg
    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)

    c_cvPyrUp(&srcimg, &outimg, 7)

    PyMem_Free(outshape)

    return out


#------------
# cvWatershed
#------------

@cvdoc(package='cv', group='image', doc=\
'''cvWatershed(src, markers)

Performs watershed segmentation.

Parameters
----------
src : ndarray, 3D, dtype=uint8
    The source image.
markers : ndarray, 2D, dtype=int32
    The markers identifying the regions of interest.
    Marker values should be non-zero.
    This array should have the same width and height as src.

Returns
-------
None : None
    The markers array is modified in place. The results of which
    identify the segmented regions of the image.''')
def cvWatershed(src, markers):

    validate_array(src)
    validate_array(markers)

    assert_ndims(src, [3])
    assert_dtype(src, [UINT8])

    assert_ndims(markers, [2])
    assert_dtype(markers, [INT32])

    #assert src.shape[:2] == markers.shape[:2], \
    #                'The src and markers array must have same width and height'

    cdef IplImage srcimg
    cdef IplImage markersimg

    populate_iplimage(src, &srcimg)
    populate_iplimage(markers, &markersimg)

    c_cvWatershed(&srcimg, &markersimg)

    return None


#-------------------
# cvCalibrateCamera2
#-------------------

@cvdoc(package='cv', group='calibration', doc=\
'''cvCalibrateCamera2(object_points, image_points, point_counts, image_size)

Finds the intrinsic and extrinsic camera parameters
using a calibration pattern.

Parameters
----------
object_points : ndarray, Nx3
    An array representing the (X, Y, Z) known coordinates of the
    calibration object.
image_points : ndarry, Nx2
    An array representing the pixel image coordinate of the
    points in object_points.
point_counts : ndarry, 1D, dtype=int32
    Vector containing the number of points in each particular view.
image_size : 2-tuple, (height, width)
    The height and width of the images used.

Returns
-------
(intrinsics, distortion) : ndarray 3x3, ndarray 5-vector
    Intrinsics is the 3x3 camera instrinsics matrix.
    Distortion is the 5-vector of distortion coefficients.''')
def cvCalibrateCamera2(np.ndarray object_points, np.ndarray image_points,
           np.ndarray point_counts, image_size):

    # Validate input
    validate_array(object_points)
    assert_ndims(object_points, [2])

    validate_array(image_points)
    assert_ndims(image_points, [2])

    assert_dtype(point_counts, [INT32])
    assert_ndims(point_counts, [1])

    if not object_points.shape[1] == 3:
        raise ValueError("Object points must be Nx3")

    if not image_points.shape[1] == 2:
        raise ValueError("Image points must be Nx2")

    if not len(image_points) == len(object_points):
        raise ValueError("Must provide same number of image and object points.")

    if np.sum(point_counts) != len(image_points):
        raise ValueError("Point counts must sum to length of image_points "
                         "(is %d must be %d)." % (np.sum(point_counts), len(image_points)))

    # Allocate a new intrinsics array
    cdef np.npy_intp intrinsics_shape[2]
    intrinsics_shape[0] = <np.npy_intp> 3
    intrinsics_shape[1] = <np.npy_intp> 3
    cdef np.ndarray intrinsics = new_array(2, intrinsics_shape, FLOAT64)
    cdef IplImage ipl_intrinsics
    populate_iplimage(intrinsics, &ipl_intrinsics)
    cdef CvMat* cvmat_intrinsics = cvmat_ptr_from_iplimage(&ipl_intrinsics)

    # Allocate a new distortion array
    cdef np.npy_intp distortion_shape[2]
    distortion_shape[0] = <np.npy_intp> 1
    distortion_shape[1] = <np.npy_intp> 5
    cdef np.ndarray distortion = new_array(2, distortion_shape, FLOAT64)
    cdef IplImage ipl_distortion
    populate_iplimage(distortion, &ipl_distortion)
    cdef CvMat* cvmat_distortion = cvmat_ptr_from_iplimage(&ipl_distortion)

    # Make the object & image points & npoints accessible for OpenCV
    cdef IplImage ipl_object_points, ipl_image_points, ipl_point_counts
    cdef CvMat* cvmat_object_points, *cvmat_image_points, *cvmat_point_counts
    populate_iplimage(object_points, &ipl_object_points)
    populate_iplimage(image_points, &ipl_image_points)
    populate_iplimage(point_counts, &ipl_point_counts)

    cvmat_object_points = cvmat_ptr_from_iplimage(&ipl_object_points)
    cvmat_image_points = cvmat_ptr_from_iplimage(&ipl_image_points)
    cvmat_point_counts = cvmat_ptr_from_iplimage(&ipl_point_counts)

    # Set image size
    cdef CvSize cv_image_size
    cv_image_size.height = image_size[0]
    cv_image_size.width = image_size[1]

    # Call the function
    c_cvCalibrateCamera2(cvmat_object_points, cvmat_image_points,
                         cvmat_point_counts, cv_image_size, cvmat_intrinsics,
                         cvmat_distortion, NULL, NULL, 0)

    # Convert distortion back into a vector
    distortion = np.PyArray_Squeeze(distortion)

    PyMem_Free(cvmat_intrinsics)
    PyMem_Free(cvmat_distortion)
    PyMem_Free(cvmat_object_points)
    PyMem_Free(cvmat_image_points)
    PyMem_Free(cvmat_point_counts)

    return intrinsics, distortion


#-------------
# cvUndistort2
#-------------

@cvdoc(package='cv', group='calibration', doc=\
'''cvUndistort2(src, intrinsics, distortions, new_intrinsics=None)

Undistorts an image given the camera intrinsics matrix and distortions vector.
These values can be calculated using cvCalibrateCamera2.

Parameters
----------
src : ndarray
    The image to undistort
intrinsics : ndarray, 3x3, dtype=float64
    The camera intrinsics matrix.
distortions : ndarray, 5-vector, dtype=float64
    The camera distortion coefficients.
new_intrinsics : ndarray, 3x3, dtype=float64, optional
    Determine the subset of the source image that is visible after
    correction.

Returns
-------
out : ndarray
    The undistorted image the same size and dtype
    as the source image.''')
def cvUndistort2(src, intrinsics, distortions, new_intrinsics=None):
    validate_array(src)
    assert_dtype(intrinsics, [FLOAT64])
    assert_dtype(distortions, [FLOAT64])
    assert_ndims(intrinsics, [2])
    assert_ndims(distortions, [1])

    if intrinsics.shape[0] != 3 or intrinsics.shape[1] != 3:
        raise ValueError('intrinsics must be 3x3')
    if distortions.shape[0] != 5:
        raise ValueError('distortions must be a 5-vector')

    cdef np.ndarray out = new_array_like(src)

    cdef IplImage srcimg
    cdef IplImage outimg
    cdef IplImage intrimg
    cdef IplImage distimg
    cdef IplImage new_intrinsics_img

    populate_iplimage(src, &srcimg)
    populate_iplimage(out, &outimg)
    populate_iplimage(intrinsics, &intrimg)
    populate_iplimage(distortions, &distimg)

    cdef CvMat* cvnew_intrinsics = NULL
    cdef CvMat* cvintr = cvmat_ptr_from_iplimage(&intrimg)
    cdef CvMat* cvdist = cvmat_ptr_from_iplimage(&distimg)

    if new_intrinsics is not None:
        populate_iplimage(new_intrinsics, &new_intrinsics_img)
        cvnew_intrinsics = cvmat_ptr_from_iplimage(&new_intrinsics_img)

    c_cvUndistort2(&srcimg, &outimg, cvintr, cvdist, cvnew_intrinsics)

    PyMem_Free(cvintr)
    PyMem_Free(cvdist)
    PyMem_Free(cvnew_intrinsics)

    return out

#------------------------
# cvFindChessboardCorners
#------------------------

@cvdoc(package='cv', group='calibration', doc=\
'''cvFindChessboardCorners(src, pattern_size, flag=CV_CALIB_CB_ADAPTIVE_THRESH)

Finds the position of the internal corners of a chessboard.

Parameters
----------
src : ndarray, dtype=uint8
    Image to search for chessboard corners.
pattern_size : 2-tuple of inner corners (h,w)
flag : integer
    CV_CALIB_CB_ADAPTIVE_THRESH - use adaptive thresholding
        to convert the image to black and white,
        rather than a fixed threshold level
        (computed from the average image brightness).
    CV_CALIB_CB_NORMALIZE_IMAGE - normalize the image using
        cvNormalizeHist() before applying fixed or adaptive
        thresholding.
    CV_CALIB_CB_FILTER_QUADS - use additional criteria
        (like contour area, perimeter, square-like shape) to
        filter out false quads that are extracted at the contour
        retrieval stage.

Returns
-------
out : ndarray Nx2
    An nx2 array of the corners found.''')
def cvFindChessboardCorners(np.ndarray src, pattern_size,
                            int flag=CV_CALIB_CB_ADAPTIVE_THRESH):

    validate_array(src)

    assert_nchannels(src, [1, 3])
    assert_dtype(src, [UINT8])

    cdef np.npy_intp outshape[2]
    outshape[0] = <np.npy_intp> pattern_size[0] * pattern_size[1]
    outshape[1] = <np.npy_intp> 2

    cdef np.ndarray out
    out = new_array(2, outshape, FLOAT32)
    cdef CvPoint2D32f* cvpoints = array_as_cvPoint2D32f_ptr(out)

    cdef CvSize cvpattern_size
    cvpattern_size.height = pattern_size[0]
    cvpattern_size.width = pattern_size[1]

    cdef IplImage srcimg
    populate_iplimage(src, &srcimg)

    cdef int ncorners_found
    c_cvFindChessboardCorners(&srcimg, cvpattern_size, cvpoints,
                              &ncorners_found, flag)

    return out[:ncorners_found]


#-----------------------------
# cvFindExtrinsicCameraParams2
#-----------------------------

@cvdoc(package='cv', group='calibration', doc=\
'''cvFindExtrinsicCameraParams2(object_points, image_points, intrinsic_matrix,
                                distortion_coeffs)

Calculates the extrinsic camera parameters given a set of 3D points, their
2D locations in the image, and the camera instrinsics matrix and distortion
coefficients.

i.e. given this information, it calculates the offset and rotation of the
camera from the chessboard origin.

Parameters
----------
object_points: ndarray, nx3
    The 3D coordinates of the chessboard corners.
image_points: ndarray, nx2
    The 2D image coordinates of the object_points
intrinsic_matrix: ndarray, 3x3, dtype=float64
    The 2D camera intrinsics matrix that is the result of camera calibration
distortion_coeffs: ndarray, 5-vector, dtype=float64
    The 5 distortion coefficients that are the result of camera calibration

Returns
-------
(rvec, tvec): ndarray 3-vector dtype=float64, ndarray 3-vector dtype=float64
    rvec - the rotation vector representing the rotation of the camera
    relative to the chessboard. The direction of the vector represents the
    axis of rotation and its magnitude the amount of rotation.
    tvec - the translation vector representing the offset of the camera
    relative to the chessboard origin.''')
def cvFindExtrinsicCameraParams2(object_points, image_points, intrinsic_matrix,
                                 distortion_coeffs):

    validate_array(object_points)
    validate_array(image_points)
    validate_array(intrinsic_matrix)

    assert_ndims(object_points, [2])
    assert_dtype(object_points, [FLOAT32, FLOAT64])
    assert object_points.shape[1] == 3, 'object_points should be nx3'

    assert_ndims(image_points, [2])
    assert_dtype(image_points, [FLOAT32, FLOAT64])
    assert image_points.shape[1] == 2, 'image_points should be nx2'

    assert_dtype(intrinsic_matrix, [FLOAT64])
    assert intrinsic_matrix.shape == (3, 3), 'instrinsics should be 3x3'

    assert_dtype(distortion_coeffs, [FLOAT64])
    assert distortion_coeffs.shape == (5,), 'distortions should be 5-vector'

    # allocate the numpy return arrays
    cdef np.npy_intp shape[1]
    shape[0] = 3
    cdef np.ndarray rvec = new_array(1, shape, FLOAT64)
    cdef np.ndarray tvec = new_array(1, shape, FLOAT64)

    # allocate the cv images
    cdef IplImage obj_img
    cdef IplImage img_img
    cdef IplImage intr_img
    cdef IplImage dist_img
    cdef IplImage rot_img
    cdef IplImage tran_img
    populate_iplimage(object_points, &obj_img)
    populate_iplimage(image_points, &img_img)
    populate_iplimage(intrinsic_matrix, &intr_img)
    populate_iplimage(distortion_coeffs, &dist_img)
    populate_iplimage(rvec, &rot_img)
    populate_iplimage(tvec, &tran_img)

    # allocate the cv mats
    cdef CvMat* cvobj = cvmat_ptr_from_iplimage(&obj_img)
    cdef CvMat* cvimg = cvmat_ptr_from_iplimage(&img_img)
    cdef CvMat* cvint = cvmat_ptr_from_iplimage(&intr_img)
    cdef CvMat* cvdis = cvmat_ptr_from_iplimage(&dist_img)
    cdef CvMat* cvrot = cvmat_ptr_from_iplimage(&rot_img)
    cdef CvMat* cvtrn = cvmat_ptr_from_iplimage(&tran_img)

    # the last argument is new to OpenCV 2.0 and tells it NOT to use
    # an extrinsics guess
    c_cvFindExtrinsicCameraParams2(cvobj, cvimg, cvint, cvdis, cvrot, cvtrn, 0)

    PyMem_Free(cvobj)
    PyMem_Free(cvimg)
    PyMem_Free(cvint)
    PyMem_Free(cvdis)
    PyMem_Free(cvrot)
    PyMem_Free(cvtrn)

    return (rvec, tvec)

#---------------------
# cvFindFundamentalMat
#---------------------

@cvdoc(package='cv', group='calibration', doc=\
'''cvFindFundamentalMat(points1, points2, int method=CV_FM_RANSAC,
                        double param1=1, double param2=0.99)

Calculates the fundamental matrix from the corresponding points in two images.

Parameters
----------
points1 : ndarray, Nx2 or Nx3, dtype=float
    Points from the first image.
points2 : ndarray, Nx3 or Nx3, dtype=float
    Points from the second image (same length as ``points1``).
method : integer
    CV_FM_7POINT - use 7-point algorithm (N = 7)
    CV_FM_8POINT - use 8-point algorithm (N = 8)
    CV_FM_RANSAC - use RANSAC algorithm (N >= 8)
    CV_FM_LMEDS - use LMedS algorithm (N >= 8)
param1 : float
    In RANSAC, the maximum distance from point to epipolar lines
    (in pixels) beyond which the point is considered an outlier.
param2 : float
    In RANSAC and LMedS, the level of confidence (probability)
    that the estimated matrix is correct.

Returns
-------
fundamental_matrix : ndarray, 3x3 or 3x3x3
    Fundamental matrix. The 7-point method may return up to three
    matrices, stored as a 3x3x3 array. If no matrix could be found,
    None is returned.
status : ndarray, length N, dtype=bool
    Currently, this is only a placeholder for future use.

    In future, should indicate whether a data-point is an inlier
    (True) or outlier (False). Only used by RANSAC and MLedS; other
    methods set all True.''')
def cvFindFundamentalMat(points1, points2, int method=CV_FM_RANSAC,
                         double param1=1, double param2=0.99):
    validate_array(points1)
    validate_array(points2)

    assert_ndims(points1, [2])
    assert_ndims(points2, [2])
    assert_dtype(points1, [FLOAT32, FLOAT64])
    assert_dtype(points2, [FLOAT32, FLOAT64])

    if not points1.shape[1] in (2, 3):
        raise ValueError("Points should be Nx2 or Nx3 arrays")

    if not method in (CV_FM_7POINT, CV_FM_8POINT, CV_FM_RANSAC, CV_FM_LMEDS):
        raise ValueError("Invalid method specified")

    if not points1.shape[0] == points2.shape[0]:
        raise ValueError("Points1 and points2 should be of equal length.")

    # allocate the numpy return arrays
    cdef np.npy_intp fundamental_shape[2]

    if (method == CV_FM_7POINT):
        fundamental_shape[0] = <np.npy_intp> 9
    else:
        fundamental_shape[0] = <np.npy_intp> 3
    fundamental_shape[1] = <np.npy_intp> 3

    cdef np.ndarray F = new_array(2, fundamental_shape, FLOAT64)

    ## The code snippet below creates the ``status`` matrix
    ## that may optionally be provided.  I could not get this
    ## to work with OpenCV 2.1.

    cdef np.npy_intp status_shape[2]
    status_shape[0] = <np.npy_intp> points1.shape[0]
    status_shape[1] = <np.npy_intp> 1
    cdef np.ndarray status = new_array(2, status_shape, UINT8)
    status.fill(0)

    ## cdef IplImage status_img
    ## populate_iplimage(status, &status_img)
    ## cdef CvMat* cvstatus = cvmat_ptr_from_iplimage(&status_img)

    # Allocate cv images
    cdef IplImage points1_img
    cdef IplImage points2_img
    cdef IplImage F_img

    populate_iplimage(points1, &points1_img)
    populate_iplimage(points2, &points2_img)
    populate_iplimage(F, &F_img)

    # Allocate cv matrices
    cdef CvMat* cvpoints1 = cvmat_ptr_from_iplimage(&points1_img)
    cdef CvMat* cvpoints2 = cvmat_ptr_from_iplimage(&points2_img)
    cdef CvMat* cvF = cvmat_ptr_from_iplimage(&F_img)

    cdef int m = c_cvFindFundamentalMat(cvpoints1, cvpoints2, cvF, method,
                                        param1, param2, NULL)

    PyMem_Free(cvpoints1)
    PyMem_Free(cvpoints2)
    PyMem_Free(cvF)
    # PyMem_Free(cvstatus)

    if m == 0:
        return (None, status)
    else:
        return (F.reshape((m, 3, 3)).squeeze(), status)


#------------------------
# cvFindChessboardCorners
#------------------------

@cvdoc(package='cv', group='calibration', doc=\
'''cvDrawChessboardCorners(src, pattern_size, corners, in_place=False)

Renders found chessboard corners into an image.

Parameters
----------
src : ndarray, dim 3, dtype: uint8
    Image to draw into.
pattern_size : 2-tuple, (h, w)
    Number of inner corners (h,w)
corners : ndarray, nx2, dtype=float32
    Corners found in the image. See cvFindChessboardCorners and
    cvFindCornerSubPix
in_place: bool
    If true, perform the drawing on the submitted
    image. If false, a copy of the image will be made and drawn to.

Returns
-------
out/None : ndarray or none
    If in_place is True, the function returns None.
    Otherwise, the function returns a new image with
    the corners drawn into it.''')
def cvDrawChessboardCorners(np.ndarray src, pattern_size, np.ndarray corners,
                            in_place=False):

    validate_array(src)

    assert_nchannels(src, [3])
    assert_dtype(src, [UINT8])

    assert_ndims(corners, [2])
    assert_dtype(corners, [FLOAT32])

    cdef np.ndarray out

    if not in_place:
        out = src.copy()
    else:
        out = src

    cdef CvSize cvpattern_size
    cvpattern_size.height = pattern_size[0]
    cvpattern_size.width = pattern_size[1]

    cdef IplImage outimg
    populate_iplimage(out, &outimg)

    cdef CvPoint2D32f* cvcorners = array_as_cvPoint2D32f_ptr(corners)

    cdef int ncount = pattern_size[0] * pattern_size[1]

    cdef int pattern_was_found

    if corners.shape[0] == ncount:
        pattern_was_found = 1
    else:
        pattern_was_found = 0

    c_cvDrawChessboardCorners(&outimg, cvpattern_size, cvcorners,
        ncount, pattern_was_found)

    if in_place:
        return None
    else:
        return out


#------------
# cvFloodFill
#------------

@cvdoc(package='cv', group='image', doc=\
'''cvFloodFill(np.ndarray src, seed_point, new_val, low_diff, high_diff,
                         mask=None, connect_diag=False, mask_only=False,
                         mask_fillval=None, fixed_range=False)

Fills a connected component with the given color.

Parameters
----------
src : ndarray, ndims=[2, 3], dtypes[uint8, float32]
    The source image
seed_point : (x, y) int tuple
    The starting point of the fill in image pixel coordinates.
new_val : scalar double or 3-tuple (R, G, B) doubles
    The color value of the repainted area. If a scalar, the RGB values
    are all set equal to the scalar.
low_diff : scalar double or 3-tuple (R, G, B) doubles
    Maximal lower brightness/color difference between the currently
    observed pixel and one of its neighbors belonging to the component,
    or a seed pixel being added to the component. Must be positive.
high_diff : scalar double or 3-tuple (R, G, B) doubles
    Maximal upper brightness/color difference between the currently
    observed pixel and one of its neighbors belonging to the component,
    or a seed pixel being added to the component. Must be positive.
mask : ndarray 2d, dtype=uint8 or None
    The mask in which to draw the results and/or use as a mask.
    See the opencv documentation for more details.
    If not None, the mask shape must be 2 pixels wider and taller than src.
connect_diag : bool
    If True, implies connectivity across the diagonals in addition to
    the standard horizontal and vertical directions.
mask_only : bool
    If True, fill the mask instead of the image.
    Mask must not be None
mask_fillval : int 0 - 255 or None
    The value to fill the mask if mask is not None.
    If None, defaults to 1
fixed_range : bool
    If True, fills relative to seed value, else, fills relative to
    neighbors value.

Returns
-------
None : None
    This is an in-place operation which draws into src and/or image depending
    on the flags set in the input arguments''')
def cvFloodFill(np.ndarray src, seed_point, new_val, low_diff, high_diff,
                mask=None, connect_diag=False, mask_only=False,
                mask_fillval=None, fixed_range=False):

    validate_array(src)
    assert_ndims(src, [2, 3])
    assert_dtype(src, [UINT8, FLOAT32])

    # src
    cdef IplImage srcimg
    populate_iplimage(src, &srcimg)

    # seed_point
    if len(seed_point) != 2:
        raise ValueError('seed_point should be an (x, y) tuple of ints')
    cdef CvPoint cv_seed_point
    cdef int x = <int>seed_point[0]
    cdef int y = <int>seed_point[1]
    cdef int xmax = <int>src.shape[1]
    cdef int ymax = <int>src.shape[0]
    if x < 0 or x > xmax or y < 0 or y > ymax:
        raise ValueError('seed_point must be image pixel coordinates')
    cv_seed_point.x = x
    cv_seed_point.y = y

    # loop counter
    cdef int i
    cdef double temp

    # new_val
    cdef CvScalar cv_new_val
    if hasattr(new_val, '__len__'):
        if len(new_val) != 3:
            raise ValueError('If not a scalar, new_val must be 3 tuple')
        for i in range(3):
            cv_new_val.val[i] = <double>new_val[i]
    else:
        temp = <double>new_val
        for i in range(3):
            cv_new_val.val[i] = temp

    # low_diff
    cdef CvScalar cv_low_diff
    if hasattr(low_diff, '__len__'):
        if len(low_diff) != 3:
            raise ValueError('If not a scalar, low_diff must be 3 tuple')
        for i in range(3):
            cv_low_diff.val[i] = <double>low_diff[i]
    else:
        temp = <double>low_diff
        for i in range(3):
            cv_low_diff.val[i] = temp

    # high_diff
    cdef CvScalar cv_high_diff
    if hasattr(high_diff, '__len__'):
        if len(high_diff) != 3:
            raise ValueError('If not a scalar, high_diff must be 3 tuple')
        for i in range(3):
            cv_high_diff.val[i] = <double>high_diff[i]
    else:
        temp = <double>high_diff
        for i in range(3):
            cv_high_diff.val[i] = temp

    # mask
    cdef IplImage maskimg
    cdef IplImage* maskimgptr = NULL
    if mask is not None:
        validate_array(mask)
        assert_ndims(mask, [2])
        assert_dtype(mask, [UINT8])
        if mask.shape[0] != (src.shape[0] +  2) or \
        mask.shape[1] != (src.shape[1] + 2):
            raise ValueError('mask must be 2 pixels wider and taller than src.')
        populate_iplimage(mask, &maskimg)
        maskimgptr = &maskimg

    # flags
    cdef int flags

    # connect_diag
    cdef int cv_connect_diag = 4
    if connect_diag:
        cv_connect_diag = 8

    # mask_only
    cdef int cv_mask_only = 0
    if mask_only:
        if mask is None:
            raise ValueError('If mask_only==True, mask must not be None')
        cv_mask_only = (1 << 17)

    # mask_fillval
    cdef int cv_mask_fillval = (1 << 8)
    if mask_fillval:
        if mask_fillval < 0 or mask_fillval > 255:
            raise ValueError('mask_fillval must be in range 0-255')
        cv_mask_fillval = ((<int>mask_fillval) << 8)

    # fixed_range
    cdef int cv_fixed_range = 0
    if fixed_range:
        cv_fixed_range = (1 << 16)

    flags = cv_connect_diag | cv_mask_only | cv_mask_fillval | cv_fixed_range

    c_cvFloodFill(&srcimg, cv_seed_point, cv_new_val, cv_low_diff, cv_high_diff,
                  NULL, flags, maskimgptr)

    return None


#----------------
# cvMatchTemplate
#----------------

@cvdoc(package='cv', group='image', doc=\
'''cvMatchTemplate(src, template, method)

Compares a template against overlapped image regions and returns a match array
dependent on the match method requested.

Parameters
----------
src : ndarray, ndims=[2, 3], dtype=[uint8, float32]
    The source image.
template : ndarray, ndim=src.ndim, dtype=src.dtype
    The template to match in the source.
method : int
    The method to use for matching.
    One of:
        CV_TM_SQDIFF
        CV_TM_SQDIFF_NORMED
        CV_TM_CCORR
        CV_TM_CCORR_NORMED
        CV_TM_CCOEFF
        CV_TM_CCOEFF_NORMED

Returns
-------
out : ndarray, 2d, dtype=float3d
    The results of the template matching.
    The size of this array (H - h + 1) x (W - w + 1)
    where (H, W) is (Height, Width) of src and (h, w) is
    (height, width) of template.

Notes
-----
After the function finishes the comparison, the best matches can be found
as global minimums (CV_TM_SQDIFF) or maximums (CV_TM_CCORR and CV_TM_CCOEFF)
using the appropriate numpy functions. In the case of a color image,
template summation in the numerator and each sum in the denominator
is done over all of the channels (and separate mean values are used for each
channel).''')
def cvMatchTemplate(np.ndarray src, np.ndarray template, int method):

    validate_array(src)
    validate_array(template)

    assert_ndims(src, [2, 3])
    assert_dtype(src, [UINT8, FLOAT32])

    assert_ndims(template, [src.ndim])
    assert_dtype(template, [src.dtype])

    if method not in [CV_TM_SQDIFF_NORMED, CV_TM_CCORR, CV_TM_CCORR_NORMED,
                      CV_TM_CCOEFF, CV_TM_CCOEFF_NORMED]:
        raise ValueError('Unknown method type')

    if src.shape[0] <= template.shape[0] or src.shape[1] <= template.shape[1]:
        raise ValueError('template must be smaller than source image')

    cdef np.npy_intp outshape[2]
    outshape[0] = <np.npy_intp>(src.shape[0] - template.shape[0] + 1)
    outshape[1] = <np.npy_intp>(src.shape[1] - template.shape[1] + 1)
    cdef np.ndarray out = new_array(2, outshape, FLOAT32)

    cdef IplImage srcimg
    cdef IplImage templateimg
    cdef IplImage outimg

    populate_iplimage(src, &srcimg)
    populate_iplimage(template, &templateimg)
    populate_iplimage(out, &outimg)

    c_cvMatchTemplate(&srcimg, &templateimg, &outimg, method)

    return out
