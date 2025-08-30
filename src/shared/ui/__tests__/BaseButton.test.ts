import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import BaseButton from '../BaseButton.vue'

describe('BaseButton', () => {
  it('renders correctly with default props', () => {
    const wrapper = mount(BaseButton, {
      slots: {
        default: 'Click me'
      }
    })

    expect(wrapper.text()).toBe('Click me')
    expect(wrapper.classes()).toContain('bg-primary-600')
    expect(wrapper.classes()).toContain('hover:bg-primary-700')
  })

  it('applies correct variant classes', () => {
    const wrapper = mount(BaseButton, {
      props: {
        variant: 'danger'
      },
      slots: {
        default: 'Delete'
      }
    })

    expect(wrapper.classes()).toContain('bg-red-600')
    expect(wrapper.classes()).toContain('hover:bg-red-700')
  })

  it('shows loading state', () => {
    const wrapper = mount(BaseButton, {
      props: {
        loading: true,
        loadingText: 'Carregando...'
      },
      slots: {
        default: 'Submit'
      }
    })

    expect(wrapper.text()).toBe('Carregando...')
    expect(wrapper.find('svg').exists()).toBe(true)
  })

  it('emits click event', async () => {
    const wrapper = mount(BaseButton, {
      slots: {
        default: 'Click me'
      }
    })

    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toBeTruthy()
  })

  it('is disabled when loading', () => {
    const wrapper = mount(BaseButton, {
      props: {
        loading: true
      }
    })

    expect(wrapper.attributes('disabled')).toBeDefined()
  })
})
