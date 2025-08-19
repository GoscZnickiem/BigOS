/******************************************************************************
 *
 *  Project:		BigOS
 *  File:			bootloader/fdt.c
 *
 ******************************************************************************/

#include "fdt.h"

#include <efierr.h>
#include <efilib.h>

#include "common.h"
#include "error.h"
#include "guid.h"
#include "log.h"

#define EFI_FDT_GUID                                                                  \
	{                                                                                 \
	    0xb1b621d5, 0xf19c, 0x41a5, {0x83, 0x0b, 0xd9, 0x15, 0x2c, 0x69, 0xaa, 0xe0} \
}

void* g_fdt;

VOID print_guid(IN EFI_GUID *Guid) {
    log(L"%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
          Guid->Data1,
          Guid->Data2,
          Guid->Data3,
          Guid->Data4[0], Guid->Data4[1],
          Guid->Data4[2], Guid->Data4[3],
          Guid->Data4[4], Guid->Data4[5],
          Guid->Data4[6], Guid->Data4[7]);
}

// FDT is created by u-boot and then passed into UEFI system table
status_t get_FDT(void) {
	START;
	EFI_GUID fdt_guid = EFI_FDT_GUID;
	EFI_CONFIGURATION_TABLE* entry;

	for (UINTN index = 0; index < g_system_table->NumberOfTableEntries; ++index) {
		entry = &g_system_table->ConfigurationTable[index];
		if (guid_compare(&entry->VendorGuid, &fdt_guid)) {
			print_guid(&entry->VendorGuid);
			print_guid(&fdt_guid);
			g_fdt = entry->VendorTable;
			log(L"FDT address: %lX", g_fdt);
			log(L"Contents:");
			for(UINTN i = 0; i < 15; ++i) {
				log(L"%lX", ((UINT64*)g_fdt)[i]);
			}
			RETURN(BOOT_SUCCESS);
		}
	}

	RETURN(BOOT_ERROR);
}
