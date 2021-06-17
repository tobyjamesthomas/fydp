import React, {useRef, useState} from 'react';
import Popup from './Popup';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  View,
  Platform,
  Pressable,
  Animated,
  Easing,
  useColorScheme,
  Linking,
} from 'react-native';
import logo from './logo.png';

const isNative = Platform.OS !== 'web';

const App = () => {
  const [wasRotated, setwasRotated] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const spinValue = useRef(new Animated.Value(3)).current;
  const isDarkMode = useColorScheme() === 'dark';
  const togglePopup = () => {
    setIsOpen(!isOpen);
  }
  const onPressRight = () => {
    setwasRotated(!wasRotated);
    Animated.timing(spinValue, {
      toValue: wasRotated ? 0 : 1,
      duration: 1250,
      easing: Easing.linear,
      useNativeDriver: true,
    }).start();
  };
  const onPress = () => {
    setwasRotated(!wasRotated);
    Animated.timing(spinValue, {
      toValue: wasRotated ? 0 : 1,
      duration: 1250,
      easing: Easing.linear,
      useNativeDriver: true,
    }).start();
  };

  const spin = spinValue.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  return (
    <SafeAreaView style={styles.scrollView}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={styles.scrollView}
        contentContainerStyle={styles.scrollView}>
        <View style={styles.container}>
          <Animated.Image
            source={logo}
            style={[styles.logo, {transform: [{rotate: spin}]}]}
          />
          <Text style={styles.title}>Welcome to Eye Tracking</Text>
          <Text style={styles.text}>
            'Follow the instructions on the page.'
          </Text>
          {isNative && (
            <Text style={styles.text}>
              Shake your phone to open the developer menu.
            </Text>
          )}
          <Text
            style={styles.link}
            onPress={
              isNative
                ? () =>
                    Linking.openURL(
                      'https://github.com/necolas/react-native-web',
                    )
                : undefined
            }
            accessibilityRole="link"
            href="https://github.com/necolas/react-native-web"
            target="_blank">
            Click here to learn more about react native web
          </Text>
          <input
            type="button"
            value="Click to Open Popup"
            onClick={togglePopup}
          />
          <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
          {isOpen && <Popup
            content={<>
                <b>Design your Popup</b>
                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
                <button>Test button</button>
            </>}
          handleClose={togglePopup}
          />}
          <Pressable
            onPress={onPress}
            style={styles.button}
            underlayColor={'#0A84D0'}>
            <View>
              <Text style={styles.buttonText}>Rotate Logo</Text>
            </View>
          </Pressable>
          <Pressable
            onPress={onPressRight}
            style={styles.button}
            underlayColor={'#0A84D0'}>
            <View>
              <Text style={styles.buttonText}>usr looked right</Text>
            </View>
          </Pressable>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  scrollView: {
    width: '100%',
    flex: 1,
  },
  container: {
    flex: 1,
    backgroundColor: '#282c34',
    alignItems: 'center',
    justifyContent: 'center',
  },
  logo: {
    width: 300,
    height: 300,
  },
  title: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 16,
  },
  text: {
    color: '#fff',
  },
  link: {
    color: '#1B95E0',
  },
  button: {
    borderRadius: 3,
    padding: 20,
    marginVertical: 10,
    marginTop: 10,
    backgroundColor: '#1B95E0',
  },
  buttonText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 16,
  },
});

export default App;
