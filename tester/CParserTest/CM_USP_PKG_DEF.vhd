--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;
library ctrl_lib;
use ctrl_lib.CM_USP.all;
library shared_lib;
use shared_lib.common_ieee.all;


package CM_USP_DEF is
  constant DEFAULT_CM_USP_CM_CTRL_CTRL_t : CM_USP_CM_CTRL_CTRL_t := (
                                                                     ENABLE_UC => '0',
                                                                     ENABLE_PWR => '0',
                                                                     OVERRIDE_PWR_GOOD => '0',
                                                                     ERROR_STATE_RESET => '0'
                                                                    );
  constant DEFAULT_CM_USP_CM_C2C_STATUS_CTRL_t : CM_USP_CM_C2C_STATUS_CTRL_t := (
                                                                                 INITIALIZE => '0'
                                                                                );
  constant DEFAULT_CM_USP_CM_C2C_LINK_DEBUG_RX_CTRL_t : CM_USP_CM_C2C_LINK_DEBUG_RX_CTRL_t := (
                                                                                               BUF_RESET => '0',
                                                                                               CDR_HOLD => '0',
                                                                                               DFE_LPM_RESET => '0',
                                                                                               LPM_EN => '0',
                                                                                               PCS_RESET => '0',
                                                                                               PMA_RESET => '0',
                                                                                               PRBS_CNT_RST => '0',
                                                                                               PRBS_SEL => (others => '0'),
                                                                                               RATE => (others => '0')
                                                                                              );
  constant DEFAULT_CM_USP_CM_C2C_LINK_DEBUG_TX_CTRL_t : CM_USP_CM_C2C_LINK_DEBUG_TX_CTRL_t := (
                                                                                               INHIBIT => '0',
                                                                                               PCS_RESET => '0',
                                                                                               PMA_RESET => '0',
                                                                                               POLARITY => '0',
                                                                                               POST_CURSOR => (others => '0'),
                                                                                               PRBS_FORCE_ERR => '0',
                                                                                               PRE_CURSOR => (others => '0'),
                                                                                               PRBS_SEL => (others => '0'),
                                                                                               DIFF_CTRL => (others => '0')
                                                                                              );
  constant DEFAULT_CM_USP_CM_C2C_LINK_DEBUG_CTRL_t : CM_USP_CM_C2C_LINK_DEBUG_CTRL_t := (
                                                                                         EYESCAN_RESET => '0',
                                                                                         EYESCAN_TRIGGER => '0',
                                                                                         PCS_RSV_DIN => (others => '0'),
                                                                                         RX => DEFAULT_CM_USP_CM_C2C_LINK_DEBUG_RX_CTRL_t,
                                                                                         TX => DEFAULT_CM_USP_CM_C2C_LINK_DEBUG_TX_CTRL_t
                                                                                        );
  constant DEFAULT_CM_USP_CM_C2C_CNT_CTRL_t : CM_USP_CM_C2C_CNT_CTRL_t := (
                                                                           RESET_COUNTERS => '0'
                                                                          );
  constant DEFAULT_CM_USP_CM_C2C_CTRL_t : CM_USP_CM_C2C_CTRL_t := (
                                                                   ENABLE_PHY_CTRL => '1',
                                                                   PHY_LANE_STABLE => x"000000ff",
                                                                   PHY_READ_TIME => x"4c4b40",
                                                                   STATUS => DEFAULT_CM_USP_CM_C2C_STATUS_CTRL_t,
                                                                   LINK_DEBUG => DEFAULT_CM_USP_CM_C2C_LINK_DEBUG_CTRL_t,
                                                                   CNT => DEFAULT_CM_USP_CM_C2C_CNT_CTRL_t
                                                                  );
  constant DEFAULT_CM_USP_CM_MONITOR_ERRORS_CTRL_t : CM_USP_CM_MONITOR_ERRORS_CTRL_t := (
                                                                                         RESET => '0'
                                                                                        );
  constant DEFAULT_CM_USP_CM_MONITOR_CTRL_t : CM_USP_CM_MONITOR_CTRL_t := (
                                                                           COUNT_16X_BAUD => x"1b",
                                                                           ERRORS => DEFAULT_CM_USP_CM_MONITOR_ERRORS_CTRL_t,
                                                                           SM_TIMEOUT => x"0001fca0"
                                                                          );
  constant DEFAULT_CM_USP_CM_CTRL_t : CM_USP_CM_CTRL_t := (
                                                           CTRL => DEFAULT_CM_USP_CM_CTRL_CTRL_t,
                                                           C2C => (others => DEFAULT_CM_USP_CM_C2C_CTRL_t ),
                                                           MONITOR => DEFAULT_CM_USP_CM_MONITOR_CTRL_t
                                                          );
  constant DEFAULT_CM_USP_CTRL_t : CM_USP_CTRL_t := (
                                                     CM => (others => DEFAULT_CM_USP_CM_CTRL_t )
                                                    );

end package;
