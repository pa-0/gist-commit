package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"syscall"
	"time"
	"unsafe"

	"golang.org/x/sys/windows/svc"
	"golang.org/x/sys/windows/svc/eventlog"
	"golang.org/x/sys/windows/svc/mgr"
)

var (
	advapi32 = syscall.NewLazyDLL("advapi32.dll")
	kernel32 = syscall.NewLazyDLL("kernel32.dll")
	userenv  = syscall.NewLazyDLL("userenv.dll")
	wtsapi32 = syscall.NewLazyDLL("wtsapi32.dll")

	procGetUserProfileDirectory      = userenv.NewProc("GetUserProfileDirectoryW")
	procWTSGetActiveConsoleSessionId = kernel32.NewProc("WTSGetActiveConsoleSessionId")
	procWTSQueryUserToken            = wtsapi32.NewProc("WTSQueryUserToken")
	procGetTokenInformation          = advapi32.NewProc("GetTokenInformation")
)

const (
	CREATE_BREAKAWAY_FROM_JOB = 0x01000000
	CREATE_NEW_CONSOLE        = 0x00000010
	CREATE_NEW_PROCESS_GROUP  = 0x00000200

	TokenLinkedToken = 19
)

type TOKEN_INFORMATION_CLASS uint32

func main() {
	serviceName := "test-linked-token"
	isIntSess, err := svc.IsAnInteractiveSession()
	if err != nil {
		log.Fatalf("failed to determine if we are running in an interactive session: %v", err)
	}
	var logFilename string
	if isIntSess {
		logFilename = `C:\gopath\src\github.com\taskcluster\test-linked-token\interactive.log`
	} else {
		logFilename = `C:\gopath\src\github.com\taskcluster\test-linked-token\service.log`
	}
	logFile, err := os.Create(logFilename)
	if err != nil {
		log.Fatalf("could not create log file %v: %v", logFilename, err)
	}
	defer logFile.Close()
	logger := log.New(logFile, "", log.LstdFlags)
	if isIntSess {
		logger.Printf("Running as an interactive process")
		err = installService(serviceName, "Test Linked Token")
		if err != nil {
			logger.Fatalf("could not install service %v: %v", serviceName, err)
		}
		defer func() {
			err = removeService(serviceName)
			if err != nil {
				logger.Fatalf("could not remove service %v: %v", serviceName, err)
			}
		}()
		err = startService(serviceName)
		if err != nil {
			logger.Fatalf("could not start service %v: %v", serviceName, err)
		}
		logger.Printf("Started service")
		return
	}
	logger.Printf("Running as a windows service")
	RunAdminCommand(logger)
}

func RunAdminCommand(logger *log.Logger) {
	token, err := InteractiveUserToken(1 * time.Minute)
	if err != nil {
		logger.Fatal(err)
	}
	linkedToken, err := GetLinkedToken(token)
	if err != nil {
		logger.Fatal(err)
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	cmd := exec.CommandContext(ctx, `C:\gopath\src\github.com\taskcluster\test-linked-token\admincommand.bat`)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	// creationFlags := uint32(CREATE_NEW_PROCESS_GROUP | CREATE_NEW_CONSOLE | CREATE_BREAKAWAY_FROM_JOB)
	cmd.SysProcAttr = &syscall.SysProcAttr{
		// Token: syscall.Token(token),
		Token: syscall.Token(linkedToken),
		// CreationFlags: creationFlags,
	}
	err = cmd.Start()
	if err != nil {
		logger.Fatal(err)
	}
	logger.Printf("Waiting for command to finish...")
	err = cmd.Wait()
	logger.Printf("Command finished with error: %v", err)
}

// InteractiveUserToken returns a user token (security context) for the
// interactive desktop session attached to the default console (i.e. what would
// be seen on a display connected directly to the computer, rather than a
// remote RDP session). It must be called from a process which is running under
// LocalSystem account in order to have the necessary privileges (typically a
// Windows service). Since the service might be running before a local logon
// occurs, a timeout can be specified for waiting for a successful logon (via
// winlogon) to occur.  The returned token can be used in e.g.
// CreateProcessAsUser system call, which allows e.g. a Windows service to run
// a process in the interactive desktop session, as if the logged in user had
// executed the process directly. The function additionally waits for the user
// profile directory to exist, before returning.
func InteractiveUserToken(timeout time.Duration) (hToken syscall.Handle, err error) {
	deadline := time.Now().Add(timeout)
	var sessionId uint32
	sessionId, err = WTSGetActiveConsoleSessionId()
	if err == nil {
		err = WTSQueryUserToken(sessionId, &hToken)
	}
	for err != nil {
		if time.Now().After(deadline) {
			return
		}
		time.Sleep(time.Second / 10)
		sessionId, err = WTSGetActiveConsoleSessionId()
		if err == nil {
			err = WTSQueryUserToken(sessionId, &hToken)
		}
	}
	// to be safe, let's make sure profile directory has already been created,
	// to avoid likely race conditions outside of this function
	var userProfileDir string
	userProfileDir, err = ProfileDirectory(hToken)
	if err == nil {
		_, err = os.Stat(userProfileDir)
	}
	for err != nil {
		if time.Now().After(deadline) {
			return
		}
		time.Sleep(time.Second / 10)
		userProfileDir, err = ProfileDirectory(hToken)
		if err == nil {
			_, err = os.Stat(userProfileDir)
		}
	}
	return
}

// https://msdn.microsoft.com/en-us/library/aa383835(VS.85).aspx
// DWORD WTSGetActiveConsoleSessionId(void);
func WTSGetActiveConsoleSessionId() (sessionId uint32, err error) {
	r1, _, _ := procWTSGetActiveConsoleSessionId.Call()
	if r1 == 0xFFFFFFFF {
		err = os.NewSyscallError("WTSGetActiveConsoleSessionId", errors.New("Got return value 0xFFFFFFFF from syscall WTSGetActiveConsoleSessionId"))
	} else {
		sessionId = uint32(r1)
	}
	return
}

// https://msdn.microsoft.com/en-us/library/aa383840(VS.85).aspx
// BOOL WTSQueryUserToken(
//      _In_  ULONG   SessionId,
//      _Out_ PHANDLE phToken
// );
func WTSQueryUserToken(
	sessionId uint32,
	phToken *syscall.Handle,
) (err error) {
	r1, _, e1 := procWTSQueryUserToken.Call(
		uintptr(sessionId),
		uintptr(unsafe.Pointer(phToken)),
	)
	if r1 == 0 {
		err = os.NewSyscallError("WTSQueryUserToken", e1)
	}
	return
}

// ProfileDirectory returns the profile directory of the user represented by
// the given user handle
func ProfileDirectory(hToken syscall.Handle) (string, error) {
	lpcchSize := uint32(0)
	GetUserProfileDirectory(hToken, nil, &lpcchSize)
	u16 := make([]uint16, lpcchSize)
	err := GetUserProfileDirectory(hToken, &u16[0], &lpcchSize)
	// bad token?
	if err != nil {
		return "", err
	}
	return syscall.UTF16ToString(u16), nil
}

// https://msdn.microsoft.com/en-us/library/windows/desktop/bb762280(v=vs.85).aspx
// BOOL WINAPI GetUserProfileDirectory(
//   _In_         HANDLE  hToken,
//   _Out_opt_ LPTSTR  lpProfileDir,
//   _Inout_   LPDWORD lpcchSize
// );
func GetUserProfileDirectory(
	hToken syscall.Handle,
	lpProfileDir *uint16,
	lpcchSize *uint32,
) (err error) {
	r1, _, e1 := procGetUserProfileDirectory.Call(
		uintptr(hToken),
		uintptr(unsafe.Pointer(lpProfileDir)),
		uintptr(unsafe.Pointer(lpcchSize)),
	)
	if r1 == 0 {
		err = os.NewSyscallError("GetUserProfileDirectory", e1)
	}
	return
}

func installService(name, desc string) error {
	exepath, err := os.Executable()
	if err != nil {
		return err
	}
	m, err := mgr.Connect()
	if err != nil {
		return err
	}
	defer m.Disconnect()
	s, err := m.OpenService(name)
	if err == nil {
		s.Close()
		return fmt.Errorf("service %s already exists", name)
	}
	s, err = m.CreateService(name, exepath, mgr.Config{DisplayName: desc})
	if err != nil {
		return err
	}
	defer s.Close()
	err = eventlog.InstallAsEventCreate(name, eventlog.Error|eventlog.Warning|eventlog.Info)
	if err != nil {
		s.Delete()
		return fmt.Errorf("SetupEventLogSource() failed: %s", err)
	}
	return nil
}

func removeService(name string) error {
	m, err := mgr.Connect()
	if err != nil {
		return err
	}
	defer m.Disconnect()
	s, err := m.OpenService(name)
	if err != nil {
		return fmt.Errorf("service %s is not installed", name)
	}
	defer s.Close()
	err = s.Delete()
	if err != nil {
		return err
	}
	err = eventlog.Remove(name)
	if err != nil {
		return fmt.Errorf("RemoveEventLogSource() failed: %s", err)
	}
	return nil
}

func startService(name string) error {
	m, err := mgr.Connect()
	if err != nil {
		return err
	}
	defer m.Disconnect()
	s, err := m.OpenService(name)
	if err != nil {
		return fmt.Errorf("could not access service: %v", err)
	}
	defer s.Close()
	err = s.Start()
	if err != nil {
		return fmt.Errorf("could not start service: %v", err)
	}
	return nil
}

// https://msdn.microsoft.com/en-us/library/windows/desktop/aa446671(v=vs.85).aspx
// BOOL WINAPI GetTokenInformation(
//   _In_      HANDLE                  TokenHandle,
//   _In_      TOKEN_INFORMATION_CLASS TokenInformationClass,
//   _Out_opt_ LPVOID                  TokenInformation,
//   _In_      DWORD                   TokenInformationLength,
//   _Out_     PDWORD                  ReturnLength
// );
func GetTokenInformation(
	tokenHandle syscall.Handle,
	tokenInformationClass TOKEN_INFORMATION_CLASS,
	tokenInformation *byte,
	tokenInformationLength uint32,
	returnLength *uint32,
) (err error) {
	r1, _, e1 := procGetTokenInformation.Call(
		uintptr(tokenHandle),
		uintptr(tokenInformationClass),
		uintptr(unsafe.Pointer(tokenInformation)),
		uintptr(tokenInformationLength),
		uintptr(unsafe.Pointer(returnLength)),
	)
	if r1 == 0 {
		err = os.NewSyscallError("GetTokenInformation", e1)
	}
	return
}

func GetLinkedToken(hToken syscall.Handle) (syscall.Handle, error) {
	tokenInformationLength := uint32(0)
	_ = GetTokenInformation(hToken, TokenLinkedToken, nil, 0, &tokenInformationLength)
	tokenInformation := make([]byte, tokenInformationLength)
	err := GetTokenInformation(hToken, TokenLinkedToken, &tokenInformation[0], tokenInformationLength, &tokenInformationLength)
	if err != nil {
		return 0, err
	}
	linkedTokenStruct := (*TOKEN_LINKED_TOKEN)(unsafe.Pointer(&tokenInformation[0]))
	return linkedTokenStruct.LinkedToken, nil
}

// https://msdn.microsoft.com/en-us/library/windows/desktop/bb530719(v=vs.85).aspx
// typedef struct _TOKEN_LINKED_TOKEN {
//   HANDLE LinkedToken;
// } TOKEN_LINKED_TOKEN, *PTOKEN_LINKED_TOKEN;
type TOKEN_LINKED_TOKEN struct {
	LinkedToken syscall.Handle // HANDLE
}