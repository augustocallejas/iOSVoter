/*
 *  Macros.h
 *  Supervote
 *
 *  Created by augusto callejas on 3/31/12.
 *  Copyright 2012 Canary Falls Software LLC. All rights reserved.
 *
 */

#ifndef Macros_h
#define Macros_h

#ifdef CONFIGURATION_Debug
	#define LogDebug(...)              LogMessageF(__FILE__,__LINE__,__FUNCTION__,nil,3,__VA_ARGS__)
	#define LogInfo(...)               LogMessageF(__FILE__,__LINE__,__FUNCTION__,nil,2,__VA_ARGS__)
	#define LogWarn(...)               LogMessageF(__FILE__,__LINE__,__FUNCTION__,nil,1,__VA_ARGS__)
	#define LogError(...)              LogMessageF(__FILE__,__LINE__,__FUNCTION__,nil,0,__VA_ARGS__)
//	#define LOG_NETWORK(level, ...)    LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"network",level,__VA_ARGS__)
//	#define LOG_GENERAL(level, ...)    LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"general",level,__VA_ARGS__)
//	#define LOG_GRAPHICS(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"graphics",level,__VA_ARGS__)
#else
	#define LogDebug(...)              do{}while(0)
	#define LogInfo(...)               do{}while(0)
	#define LogWarn(...)               do{}while(0)
	#define LogWarn(...)               do{}while(0)
#endif

#endif