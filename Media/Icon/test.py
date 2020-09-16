import cv2
import numpy as np

# Read Image
image = cv2.imread('./forcesensor.jpg', cv2.IMREAD_COLOR)

# Add alpha channel
b_channel, g_channel, r_channel = cv2.split(image)
alpha_channel = np.ones(b_channel.shape, dtype=b_channel.dtype) * 255
image = cv2.merge((b_channel, g_channel, r_channel, alpha_channel))

# Go through each pixel
nrows, ncols = image.shape [:-1]
for i in range(0, nrows):
    for j in range(0, ncols):
        # If pixel is matching color, make transparent
        if (image[i][j][:-1] >= 235).all():
            image[i][j][3] = 0

# Write modified image
cv2.imwrite('./transparentbulb.png', image)
