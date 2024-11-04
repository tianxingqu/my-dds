/**
 * @file main.cpp
 * @brief To-be-added
 * @copyright Copyright (c) 2020 YUSUR Technology Co., Ltd. All Rights Reserved. Learn more at www.yusur.tech.
 * @author TianXing Qu (qutx@yusur.tech)
 * @date 2024-04-03 16:57:43
 */

#include <gtest/gtest.h>
#include <gmock/gmock.h>

int main(int argc, char **argv)
{
    std::cout << "Running main() from: " << __FILE__ << std::endl;
    testing::InitGoogleTest(&argc, argv);
    testing::InitGoogleMock(&argc, argv);

    int result = RUN_ALL_TESTS();

    return result;
}
