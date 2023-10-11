#ifndef HID_CUSTOM_INOUT_H
#define HID_CUSTOM_INOUT_H

/*!< hidraw in endpoint */
#define HIDRAW_IN_EP       0x81
#define HIDRAW_IN_EP_SIZE  64
#define HIDRAW_IN_INTERVAL 10

/*!< hidraw out endpoint */
#define HIDRAW_OUT_EP          0x02
#define HIDRAW_OUT_EP_SIZE     64
#define HIDRAW_OUT_EP_INTERVAL 10

#define USBD_VID           0xDEAD
#define USBD_PID           0xBEEF
#define USBD_MAX_POWER     100
#define USBD_LANGID_STRING 1033


#endif /* HID_CUSTOM_INOUT_H */
