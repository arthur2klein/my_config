#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define STEP 5
#define BRIGHTNESS_VCP "10" // DDC VCP code for brightness

int exec_cmd(char *const argv[]) {
  pid_t pid = fork();
  if (pid == 0) {
    execvp(argv[0], argv);
    _exit(127);
  } else if (pid > 0) {
    int status;
    waitpid(pid, &status, 0);
    return WIFEXITED(status) && WEXITSTATUS(status) == 0;
  }
  return 0;
}

int adjust_ddc(const char *direction) {
  // Detect first display (no parsing if only one screen is assumed)
  FILE *pipe =
      popen("ddcutil detect | grep -m1 'Display ' | awk '{print $2}'", "r");
  if (!pipe)
    return 0;

  char disp[8];
  if (!fgets(disp, sizeof(disp), pipe)) {
    pclose(pipe);
    return 0;
  }
  pclose(pipe);

  int display = atoi(disp);
  if (display < 0)
    return 0;

  // Get current brightness
  char cmd[128];
  snprintf(cmd, sizeof(cmd), "ddcutil getvcp %s --display %d 2>/dev/null",
           BRIGHTNESS_VCP, display);
  pipe = popen(cmd, "r");
  if (!pipe)
    return 0;

  char line[256];
  int current = -1;
  while (fgets(line, sizeof(line), pipe)) {
    char *ptr = strstr(line, "current value =");
    if (ptr) {
        current = atoi(ptr + strlen("current value ="));
        break;
    }
  }
  pclose(pipe);

  if (current < 0)
    return 0;

  int new_val = current + (strcmp(direction, "up") == 0 ? STEP : -STEP);
  if (new_val < 0)
    new_val = 0;
  if (new_val > 100)
    new_val = 100;

  char val_str[8], disp_str[8];
  snprintf(val_str, sizeof(val_str), "%d", new_val);
  snprintf(disp_str, sizeof(disp_str), "%d", display);

  char *args[] = {"ddcutil", "setvcp", BRIGHTNESS_VCP, val_str, "--display",
                  disp_str,  NULL};
  return exec_cmd(args);
}

int adjust_brightnessctl(const char *direction) {
  char arg[16];
  snprintf(arg, sizeof(arg), "%d%%%s", STEP,
           strcmp(direction, "up") == 0 ? "+" : "-");
  char *args[] = {"brightnessctl", "set", arg, NULL};
  return exec_cmd(args);
}

int main(int argc, char *argv[]) {
  if (argc != 2 ||
      (strcmp(argv[1], "up") != 0 && strcmp(argv[1], "down") != 0)) {
    fprintf(stderr, "Usage: %s up|down\n", argv[0]);
    return 1;
  }

  if (adjust_ddc(argv[1]))
    return 0;
  if (adjust_brightnessctl(argv[1]))
    return 0;

  fprintf(stderr, "Brightness adjustment failed: no supported method found.\n");
  return 1;
}

