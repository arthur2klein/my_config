#include <ddcutil_c_api.h>
#include <ddcutil_types.h>
#include <stdio.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define BACKLIGHT_PATH "/sys/class/backlight/intel_backlight"

int read_int_file(const char *path) {
  FILE *f = fopen(path, "r");
  if (!f)
    return -1;
  int val;
  fscanf(f, "%d", &val);
  fclose(f);
  return val;
}

int write_int_file(const char *path, int val) {
  FILE *f = fopen(path, "w");
  if (!f)
    return 0;
  fprintf(f, "%d\n", val);
  fclose(f);
  return 1;
}

int adjust_sysfs_brightness(const char *direction, int step_percent) {
  char brightness_path[256], max_path[256];
  snprintf(brightness_path, sizeof(brightness_path), "%s/brightness",
           BACKLIGHT_PATH);
  snprintf(max_path, sizeof(max_path), "%s/max_brightness", BACKLIGHT_PATH);
  int current = read_int_file(brightness_path);
  int max = read_int_file(max_path);
  if (current < 0 || max <= 0)
    return 0;
  int delta = (max * step_percent) / 100;
  int new_val = current + (strcmp(direction, "up") == 0 ? delta : -delta);
  if (new_val < 0)
    new_val = 0;
  if (new_val > max)
    new_val = max;
  printf("Going from %d/%d to %d/%d", current, max, new_val, max);
  return write_int_file(brightness_path, new_val);
}

int adjust_ddc_brightness(const char *direction, int step_percent) {
  DDCA_Display_Info_List *display_list = NULL;
  if (ddca_get_display_info_list2(false, &display_list) != 0 ||
      display_list->ct == 0) {
    fprintf(stderr, "No DDC displays found.\n");
    return 0;
  }
  DDCA_Display_Ref dref = display_list->info[0].dref;
  if (dref == 0) {
    fprintf(stderr, "Invalid display reference.\n");
    return 0;
  }
  DDCA_Display_Handle handle = NULL;
  if (ddca_open_display2(dref, false, &handle) != 0) {
    fprintf(stderr, "Failed to open DDC display.\n");
    return 0;
  }
  DDCA_Non_Table_Vcp_Value val;
  if (ddca_get_non_table_vcp_value(handle, 0x10, &val) != 0) {
    fprintf(stderr, "Failed to get brightness.\n");
    ddca_close_display(handle);
    return 0;
  }
  int max = ((int)val.mh << 8) | val.ml;
  int current = ((int)val.sh << 8) | val.sl;
  int delta = (max * step_percent) / 100;
  int new_val = current + (strcmp(direction, "up") == 0 ? delta : -delta);
  if (new_val < 0)
    new_val = 0;
  if (new_val > max)
    new_val = max;
  printf("Going from %d/%d to %d/%d", current, max, new_val, max);
  if (ddca_set_non_table_vcp_value(handle, 0x10, new_val >> 8,
                                   new_val & 0xFF) != 0) {
    fprintf(stderr, "Failed to set brightness.\n");
    ddca_close_display(handle);
    return 0;
  }
  ddca_close_display(handle);
  return 1;
}

int main(int argc, char *argv[]) {
  if (argc != 2 || (strcmp(argv[1], "up") && strcmp(argv[1], "down"))) {
    fprintf(stderr, "Usage: %s up|down\n", argv[0]);
    return 1;
  }
  int success = 0;
  success = adjust_sysfs_brightness(argv[1], 5);
  if (!success) {
    success = adjust_ddc_brightness(argv[1], 5);
  }
  if (!success) {
    fprintf(stderr, "Failed to change brightness.\n");
    return 1;
  }
  return 0;
}
