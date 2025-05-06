# Onboarding UI Design

## Design System

The onboarding UI will follow the established design system from the login/signup screens:

### Colors
- Primary: `colors.primary[600]` - Used for buttons, selected states, and accents
- Background: `colors.white` - Clean white background for main content
- Text Primary: `colors.gray[900]` - Main text color
- Text Secondary: `colors.gray[500]` - Secondary text, descriptions
- Borders: `colors.gray[200]` - Borders for cards and inputs
- Error: `colors.error[600]` - For validation errors

### Typography
- Headings: Inter-Bold, 32px
- Subheadings: Inter-Regular, 15px
- Body: Inter-Regular, 15-16px
- Buttons: Inter-SemiBold, 16px

### Components
- Buttons: 48px height, 12px border radius
- Cards: 12px border radius, 1px border
- Inputs: 56px height, 12px border radius

## Screen Layouts

### Common Layout for All Screens

Each onboarding screen will follow this common layout structure:

```tsx
<KeyboardAvoidingView 
  style={{ flex: 1, backgroundColor: colors.white }}
  behavior={Platform.OS === 'ios' ? 'padding' : undefined}
  keyboardVerticalOffset={0}
>
  <ScrollView 
    contentContainerStyle={{ 
      flexGrow: 1, 
      justifyContent: 'center',
      paddingTop: 20,
      paddingBottom: 20 
    }}
    showsVerticalScrollIndicator={false}
    bounces={false}
    keyboardShouldPersistTaps="handled"
  >
    <OnboardingContainer>
      {/* Progress bar */}
      <ProgressBar current={currentStep} total={totalSteps} />
      
      {/* Screen title */}
      <OnboardingTitle>{title}</OnboardingTitle>
      <OnboardingSubtitle>{subtitle}</OnboardingSubtitle>
      
      {/* Screen-specific content */}
      <Content>
        {/* Varies by screen */}
      </Content>
      
      {/* Navigation buttons */}
      <NavigationButtons>
        <BackButton onPress={handleBack} />
        <NextButton onPress={handleNext} />
      </NavigationButtons>
      
      {/* Skip option if applicable */}
      {showSkip && <SkipButton onPress={handleSkip} />}
    </OnboardingContainer>
  </ScrollView>
</KeyboardAvoidingView>
```

## Screen Designs

### 1. Introduction Screen

```tsx
<OnboardingTitle>{t('onboarding.welcome.title')}</OnboardingTitle>
<OnboardingSubtitle>{t('onboarding.welcome.subtitle')}</OnboardingSubtitle>

<YStack alignItems="center" marginVertical={24}>
  <Image 
    source={require('@/assets/images/onboarding-welcome.png')} 
    style={{ width: 200, height: 200 }}
    resizeMode="contain" 
  />
</YStack>

<Text 
  fontFamily="Inter-Regular"
  fontSize={16}
  color={colors.gray[700]}
  textAlign="center"
  marginBottom={40}
>
  {t('onboarding.welcome.description')}
</Text>

<OnboardingButton onPress={handleNext}>
  <Text
    fontFamily="Inter-SemiBold"
    fontSize={16}
    color={colors.white}
  >
    {t('onboarding.welcome.startButton')}
  </Text>
</OnboardingButton>
```

### 2. Cigarettes Per Day Screen

```tsx
<OnboardingTitle>{t('onboarding.cigarettesPerDay.title')}</OnboardingTitle>
<OnboardingSubtitle>{t('onboarding.cigarettesPerDay.subtitle')}</OnboardingSubtitle>

<YStack gap={12} marginVertical={24}>
  {cigaretteOptions.map((option) => (
    <OptionCard
      key={option.value}
      selected={cigarettesPerDay === option.value}
      onPress={() => setCigarettesPerDay(option.value)}
      label={option.label}
      description={option.description}
    />
  ))}
  
  <OptionCard
    selected={customCigarettes}
    onPress={() => setCustomCigarettes(true)}
    label={t('onboarding.cigarettesPerDay.other')}
  >
    {customCigarettes && (
      <XStack alignItems="center" gap={8} marginTop={12}>
        <Text fontFamily="Inter-Medium">{t('onboarding.amount')}:</Text>
        <NumberSelector
          value={customCigaretteCount}
          onChange={setCustomCigaretteCount}
          min={1}
          max={100}
        />
      </XStack>
    )}
  </OptionCard>
</YStack>

<NavigationButtons>
  <BackButton onPress={handleBack} />
  <NextButton 
    onPress={handleNext} 
    disabled={!cigarettesPerDay && !customCigarettes}
  />
</NavigationButtons>
```

### 3. Pack Price Screen

```tsx
<OnboardingTitle>{t('onboarding.packPrice.title')}</OnboardingTitle>
<OnboardingSubtitle>{t('onboarding.packPrice.subtitle')}</OnboardingSubtitle>

<YStack gap={16} marginVertical={24}>
  <YStack gap={12}>
    {pricePresets.map((price) => (
      <OptionCard
        key={price}
        selected={packPrice === price}
        onPress={() => setPackPrice(price)}
        label={`$${(price / 100).toFixed(2)}`}
      />
    ))}
  </YStack>
  
  <Text
    fontFamily="Inter-Medium"
    fontSize={16}
    color={colors.gray[800]}
    marginTop={12}
  >
    {t('onboarding.packPrice.custom')}
  </Text>
  
  <XStack alignItems="center" gap={12}>
    <PriceInput
      value={customPrice}
      onChange={setCustomPrice}
      currency="$"
    />
    <NumberSelector
      value={customPrice}
      onChange={setCustomPrice}
      step={100}
      min={100}
      max={5000}
    />
  </XStack>
</YStack>

<NavigationButtons>
  <BackButton onPress={handleBack} />
  <NextButton 
    onPress={handleNext} 
    disabled={!packPrice && !customPrice}
  />
</NavigationButtons>
```

### 4. Cigarettes Per Pack Screen

```tsx
<OnboardingTitle>{t('onboarding.cigarettesPerPack.title')}</OnboardingTitle>
<OnboardingSubtitle>{t('onboarding.cigarettesPerPack.subtitle')}</OnboardingSubtitle>

<YStack gap={12} marginVertical={24}>
  {packOptions.map((option) => (
    <OptionCard
      key={option}
      selected={cigarettesPerPack === option}
      onPress={() => setCigarettesPerPack(option)}
      label={`${option}`}
    />
  ))}
  
  <OptionCard
    selected={customPackSize}
    onPress={() => setCustomPackSize(true)}
    label={t('onboarding.cigarettesPerPack.other')}
  >
    {customPackSize && (
      <XStack alignItems="center" gap={8} marginTop={12}>
        <Text fontFamily="Inter-Medium">{t('onboarding.amount')}:</Text>
        <NumberSelector
          value={customPackCount}
          onChange={setCustomPackCount}
          min={1}
          max={100}
          step={1}
        />
      </XStack>
    )}
  </OptionCard>
</YStack>

<NavigationButtons>
  <BackButton onPress={handleBack} />
  <NextButton 
    onPress={handleNext} 
    disabled={!cigarettesPerPack && !customPackSize}
  />
</NavigationButtons>
```

### 5. Goal Setting Screen

```tsx
<OnboardingTitle>{t('onboarding.goal.title')}</OnboardingTitle>
<OnboardingSubtitle>{t('onboarding.goal.subtitle')}</OnboardingSubtitle>

<YStack gap={16} marginVertical={24}>
  <OptionCard
    selected={goal === 'REDUCE'}
    onPress={() => setGoal('REDUCE')}
    label={t('onboarding.goal.reduce')}
    description={t('onboarding.goal.reduceDescription')}
  />
  
  <OptionCard
    selected={goal === 'QUIT'}
    onPress={() => setGoal('QUIT')}
    label={t('onboarding.goal.quit')}
    description={t('onboarding.goal.quitDescription')}
  />
</YStack>

<NavigationButtons>
  <BackButton onPress={handleBack} />
  <NextButton 
    onPress={handleNext} 
    disabled={!goal}
  />
</NavigationButtons>
```

### 6. Timeline Screen

```tsx
<OnboardingTitle>{t('onboarding.timeline.title')}</OnboardingTitle>
<OnboardingSubtitle>{t('onboarding.timeline.subtitle')}</OnboardingSubtitle>

<YStack gap={12} marginVertical={24}>
  <OptionCard
    selected={timeline === 'SEVEN_DAYS'}
    onPress={() => setTimeline('SEVEN_DAYS')}
    label={t('onboarding.timeline.sevenDays')}
  />
  
  <OptionCard
    selected={timeline === 'FOURTEEN_DAYS'}
    onPress={() => setTimeline('FOURTEEN_DAYS')}
    label={t('onboarding.timeline.fourteenDays')}
  />
  
  <OptionCard
    selected={timeline === 'THIRTY_DAYS'}
    onPress={() => setTimeline('THIRTY_DAYS')}
    label={t('onboarding.timeline.thirtyDays')}
  />
  
  <OptionCard
    selected={timeline === 'NO_DEADLINE'}
    onPress={() => setTimeline('NO_DEADLINE')}
    label={t('onboarding.timeline.noDeadline')}
  />
</YStack>

<NavigationButtons>
  <BackButton onPress={handleBack} />
  <NextButton 
    onPress={handleNext} 
    disabled={!timeline}
  />
</NavigationButtons>
```

### 7. Challenges Screen

```tsx
<OnboardingTitle>{t('onboarding.challenges.title')}</OnboardingTitle>
<OnboardingSubtitle>{t('onboarding.challenges.subtitle')}</OnboardingSubtitle>

<YStack gap={12} marginVertical={24}>
  <OptionCard
    selected={challenge === 'STRESS'}
    onPress={() => setChallenge('STRESS')}
    label={t('onboarding.challenges.stress')}
  />
  
  <OptionCard
    selected={challenge === 'HABIT'}
    onPress={() => setChallenge('HABIT')}
    label={t('onboarding.challenges.habit')}
  />
  
  <OptionCard
    selected={challenge === 'SOCIAL'}
    onPress={() => setChallenge('SOCIAL')}
    label={t('onboarding.challenges.social')}
  />
  
  <OptionCard
    selected={challenge === 'ADDICTION'}
    onPress={() => setChallenge('ADDICTION')}
    label={t('onboarding.challenges.addiction')}
  />
</YStack>

<NavigationButtons>
  <BackButton onPress={handleBack} />
  <NextButton 
    onPress={handleNext} 
    disabled={!challenge}
  />
</NavigationButtons>
```

### 8. App Help Screen

```tsx
<OnboardingTitle>{t('onboarding.appHelp.title')}</OnboardingTitle>
<OnboardingSubtitle>{t('onboarding.appHelp.subtitle')}</OnboardingSubtitle>

<YStack gap={12} marginVertical={24}>
  <MultiSelectOptionCard
    selected={helpPreferences.includes('REMINDERS')}
    onPress={() => toggleHelpPreference('REMINDERS')}
    label={t('onboarding.appHelp.reminders')}
  />
  
  <MultiSelectOptionCard
    selected={helpPreferences.includes('MOTIVATION')}
    onPress={() => toggleHelpPreference('MOTIVATION')}
    label={t('onboarding.appHelp.motivation')}
  />
  
  <MultiSelectOptionCard
    selected={helpPreferences.includes('TIPS')}
    onPress={() => toggleHelpPreference('TIPS')}
    label={t('onboarding.appHelp.tips')}
  />
  
  <MultiSelectOptionCard
    selected={helpPreferences.includes('TRACKING')}
    onPress={() => toggleHelpPreference('TRACKING')}
    label={t('onboarding.appHelp.tracking')}
  />
</YStack>

<NavigationButtons>
  <BackButton onPress={handleBack} />
  <NextButton 
    onPress={handleNext} 
    disabled={helpPreferences.length === 0}
  />
</NavigationButtons>
```

### 9. Product Type Screen

```tsx
<OnboardingTitle>{t('onboarding.productType.title')}</OnboardingTitle>
<OnboardingSubtitle>{t('onboarding.productType.subtitle')}</OnboardingSubtitle>

<YStack gap={12} marginVertical={24}>
  <OptionCard
    selected={productType === 'CIGARETTE_ONLY'}
    onPress={() => setProductType('CIGARETTE_ONLY')}
    label={t('onboarding.productType.cigaretteOnly')}
  />
  
  <OptionCard
    selected={productType === 'VAPE_ONLY'}
    onPress={() => setProductType('VAPE_ONLY')}
    label={t('onboarding.productType.vapeOnly')}
  />
  
  <OptionCard
    selected={productType === 'BOTH'}
    onPress={() => setProductType('BOTH')}
    label={t('onboarding.productType.both')}
  />
</YStack>

<NavigationButtons>
  <BackButton onPress={handleBack} />
  <NextButton 
    onPress={handleNext} 
    disabled={!productType}
  />
</NavigationButtons>
```

### 10. Completion Screen

```tsx
<OnboardingTitle>{t('onboarding.completion.title')}</OnboardingTitle>
<OnboardingSubtitle>{t('onboarding.completion.subtitle')}</OnboardingSubtitle>

<YStack alignItems="center" marginVertical={24}>
  <Image 
    source={require('@/assets/images/onboarding-complete.png')} 
    style={{ width: 200, height: 200 }}
    resizeMode="contain" 
  />
</YStack>

<Text 
  fontFamily="Inter-Regular"
  fontSize={16}
  color={colors.gray[700]}
  textAlign="center"
  marginBottom={40}
>
  {t('onboarding.completion.description')}
</Text>

<OnboardingButton onPress={handleComplete}>
  <Text
    fontFamily="Inter-SemiBold"
    fontSize={16}
    color={colors.white}
  >
    {t('onboarding.completion.finishButton')}
  </Text>
</OnboardingButton>
```

## Component Definitions

### ProgressBar Component

```tsx
interface ProgressBarProps {
  current: number;
  total: number;
}

const ProgressBar = ({ current, total }: ProgressBarProps) => {
  const progress = (current / total) * 100;
  
  return (
    <YStack width="100%" marginBottom={20}>
      <XStack justifyContent="space-between" marginBottom={8}>
        <Text fontSize={12} color={colors.gray[500]}>
          {t('onboarding.progress', { current, total })}
        </Text>
        <Text fontSize={12} color={colors.gray[500]}>
          {Math.round(progress)}%
        </Text>
      </XStack>
      
      <View 
        height={4} 
        width="100%" 
        backgroundColor={colors.gray[200]}
        borderRadius={2}
      >
        <View 
          height={4} 
          width={`${progress}%`} 
          backgroundColor={colors.primary[600]}
          borderRadius={2}
        />
      </View>
    </YStack>
  );
};
```

### OptionCard Component

```tsx
interface OptionCardProps {
  selected: boolean;
  onPress: () => void;
  label: string;
  description?: string;
  children?: React.ReactNode;
}

const OptionCard = ({ 
  selected, 
  onPress, 
  label, 
  description, 
  children 
}: OptionCardProps) => {
  return (
    <Pressable onPress={onPress}>
      <View 
        backgroundColor={selected ? colors.primary[50] : colors.white}
        borderColor={selected ? colors.primary[600] : colors.gray[200]}
        borderWidth={1.5}
        borderRadius={12}
        padding={16}
      >
        <XStack alignItems="center" gap={12}>
          <View 
            width={24} 
            height={24} 
            borderRadius={12}
            borderWidth={1.5}
            borderColor={selected ? colors.primary[600] : colors.gray[300]}
            backgroundColor={selected ? colors.primary[600] : 'transparent'}
            alignItems="center"
            justifyContent="center"
          >
            {selected && <Check size={16} color={colors.white} />}
          </View>
          
          <YStack flex={1}>
            <Text 
              fontFamily="Inter-Medium"
              fontSize={16}
              color={colors.gray[900]}
            >
              {label}
            </Text>
            
            {description && (
              <Text
                fontFamily="Inter-Regular"
                fontSize={14}
                color={colors.gray[600]}
                marginTop={4}
              >
                {description}
              </Text>
            )}
          </YStack>
        </XStack>
        
        {children}
      </View>
    </Pressable>
  );
};
```

### MultiSelectOptionCard Component

```tsx
interface MultiSelectOptionCardProps {
  selected: boolean;
  onPress: () => void;
  label: string;
}

const MultiSelectOptionCard = ({ 
  selected, 
  onPress, 
  label 
}: MultiSelectOptionCardProps) => {
  return (
    <Pressable onPress={onPress}>
      <View 
        backgroundColor={selected ? colors.primary[50] : colors.white}
        borderColor={selected ? colors.primary[600] : colors.gray[200]}
        borderWidth={1.5}
        borderRadius={12}
        padding={16}
      >
        <XStack alignItems="center" gap={12}>
          <View 
            width={24} 
            height={24} 
            borderRadius={4}
            borderWidth={1.5}
            borderColor={selected ? colors.primary[600] : colors.gray[300]}
            backgroundColor={selected ? colors.primary[600] : 'transparent'}
            alignItems="center"
            justifyContent="center"
          >
            {selected && <Check size={16} color={colors.white} />}
          </View>
          
          <Text 
            fontFamily="Inter-Medium"
            fontSize={16}
            color={colors.gray[900]}
          >
            {label}
          </Text>
        </XStack>
      </View>
    </Pressable>
  );
};
```

### NumberSelector Component

```tsx
interface NumberSelectorProps {
  value: number;
  onChange: (value: number) => void;
  min?: number;
  max?: number;
  step?: number;
}

const NumberSelector = ({ 
  value, 
  onChange,
  min = 0,
  max = 100, 
  step = 1
}: NumberSelectorProps) => {
  const increment = () => {
    if (value + step <= max) {
      onChange(value + step);
    }
  };
  
  const decrement = () => {
    if (value - step >= min) {
      onChange(value - step);
    }
  };
  
  return (
    <XStack alignItems="center" gap={12}>
      <Button
        width={36}
        height={36}
        borderRadius={18}
        backgroundColor={colors.gray[200]}
        onPress={decrement}
        disabled={value <= min}
      >
        <Minus size={16} color={colors.gray[700]} />
      </Button>
      
      <Text
        fontFamily="Inter-Medium"
        fontSize={16}
        color={colors.gray[900]}
        minWidth={36}
        textAlign="center"
      >
        {value}
      </Text>
      
      <Button
        width={36}
        height={36}
        borderRadius={18}
        backgroundColor={colors.gray[200]}
        onPress={increment}
        disabled={value >= max}
      >
        <Plus size={16} color={colors.gray[700]} />
      </Button>
    </XStack>
  );
};
```

### PriceInput Component

```tsx
interface PriceInputProps {
  value: number;
  onChange: (value: number) => void;
  currency?: string;
}

const PriceInput = ({ 
  value, 
  onChange,
  currency = '$'
}: PriceInputProps) => {
  // Format cents to dollars with 2 decimal places
  const formattedValue = (value / 100).toFixed(2);
  
  const handleTextChange = (text: string) => {
    // Remove currency symbol and convert to number
    const numericValue = parseFloat(text.replace(/[^0-9.]/g, ''));
    
    if (!isNaN(numericValue)) {
      // Convert dollars to cents
      onChange(Math.round(numericValue * 100));
    }
  };
  
  return (
    <View
      borderWidth={1.5}
      borderColor={colors.gray[300]}
      borderRadius={12}
      height={56}
      width={150}
    >
      <XStack alignItems="center" height="100%" paddingHorizontal={16}>
        <Text
          fontFamily="Inter-Medium"
          fontSize={16}
          color={colors.gray[900]}
          marginRight={4}
        >
          {currency}
        </Text>
        
        <TextInput
          value={formattedValue}
          onChangeText={handleTextChange}
          keyboardType="decimal-pad"
          style={{
            fontFamily: 'Inter-Medium',
            fontSize: 16,
            color: colors.gray[900],
            flex: 1,
            height: '100%',
          }}
        />
      </XStack>
    </View>
  );
};
```

### NavigationButtons Component

```tsx
interface NavigationButtonsProps {
  children: React.ReactNode;
}

const NavigationButtons = ({ children }: NavigationButtonsProps) => {
  return (
    <XStack justifyContent="space-between" marginTop={32}>
      {children}
    </XStack>
  );
};
```

### BackButton Component

```tsx
interface BackButtonProps {
  onPress: () => void;
}

const BackButton = ({ onPress }: BackButtonProps) => {
  return (
    <Button
      variant="outlined"
      backgroundColor="transparent"
      borderColor={colors.gray[200]}
      borderWidth={1.5}
      borderRadius={12}
      height={48}
      paddingHorizontal={16}
      onPress={onPress}
    >
      <XStack alignItems="center" gap={8}>
        <ArrowLeft size={18} color={colors.gray[700]} />
        <Text
          fontFamily="Inter-Medium"
          fontSize={15}
          color={colors.gray[700]}
        >
          {t('onboarding.back')}
        </Text>
      </XStack>
    </Button>
  );
};
```

### NextButton Component

```tsx
interface NextButtonProps {
  onPress: () => void;
  disabled?: boolean;
}

const NextButton = ({ onPress, disabled }: NextButtonProps) => {
  return (
    <Button
      backgroundColor={colors.primary[600]}
      borderRadius={12}
      height={48}
      paddingHorizontal={16}
      onPress={onPress}
      disabled={disabled}
      opacity={disabled ? 0.6 : 1}
    >
      <XStack alignItems="center" gap={8}>
        <Text
          fontFamily="Inter-SemiBold"
          fontSize={15}
          color={colors.white}
        >
          {t('onboarding.next')}
        </Text>
        <ArrowRight size={18} color={colors.white} />
      </XStack>
    </Button>
  );
};
```

## Translations

Add the following translations to the i18n/translations.ts file:

```typescript
onboarding: {
  progress: '{{current}} of {{total}}',
  back: 'Back',
  next: 'Next',
  skip: 'Skip',
  
  welcome: {
    title: 'Welcome to NicotinAI',
    subtitle: 'Your personal quit smoking assistant',
    description: 'Answer a few questions to help us personalize your journey to a smoke-free life.',
    startButton: 'Get Started',
  },
  
  cigarettesPerDay: {
    title: 'How many cigarettes do you smoke per day?',
    subtitle: 'This helps us understand your habit level',
    other: 'Other amount',
    low: '5 (Low)',
    moderate10: '10 (Moderate)',
    moderate15: '15 (Moderate)',
    high20: '20 (High)',
    high25: '25 (High)',
    veryHigh30: '30 (Very high)',
    veryHigh35: '35 (Very high)',
    veryHigh40: '40+ (Very high)',
  },
  
  amount: 'Amount',
  
  packPrice: {
    title: 'How much does a pack of cigarettes cost?',
    subtitle: 'This helps us calculate your financial savings',
    custom: 'Custom amount:',
  },
  
  cigarettesPerPack: {
    title: 'How many cigarettes come in a pack?',
    subtitle: 'Select the standard quantity for your cigarette packs',
    other: 'Other amount',
  },
  
  goal: {
    title: 'What is your goal?',
    subtitle: 'Select what you want to achieve',
    reduce: 'Reduce gradually',
    reduceDescription: 'Reduce the number of cigarettes over time',
    quit: 'Quit completely',
    quitDescription: 'Stop smoking entirely',
  },
  
  timeline: {
    title: 'When do you want to achieve your goal?',
    subtitle: 'Set a timeline that feels achievable for you',
    sevenDays: 'In 7 days',
    fourteenDays: 'In 14 days',
    thirtyDays: 'In 30 days',
    noDeadline: 'No deadline',
  },
  
  challenges: {
    title: 'What makes quitting difficult for you?',
    subtitle: 'Identifying your main challenge helps us provide better support',
    stress: 'Stress',
    habit: 'Daily habit',
    social: 'Social pressure',
    addiction: 'Nicotine addiction',
  },
  
  appHelp: {
    title: 'How can the app help you?',
    subtitle: 'Select all that apply',
    reminders: 'Reminders and alerts',
    motivation: 'Daily motivation',
    tips: 'Tips to resist cravings',
    tracking: 'Track my progress',
  },
  
  productType: {
    title: 'What type of product do you use?',
    subtitle: 'Select what applies to you',
    cigaretteOnly: 'Cigarettes only',
    vapeOnly: 'Vape only',
    both: 'Both cigarettes and vape',
  },
  
  completion: {
    title: 'You're all set!',
    subtitle: 'Your personalized journey begins now',
    description: 'We've created a customized plan based on your answers. Your journey to becoming smoke-free starts now!',
    finishButton: 'Start My Journey',
  },
},
```

With these UI designs and components, we can now create a consistent and user-friendly onboarding experience that matches the design language of the existing authentication screens.